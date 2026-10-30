/*
 * mips64r5900el-ps2-elf-pkg-config.exe
 *
 * Versao Windows do script sh do PS2SDK (ps2sdk/bin/mips64r5900el-ps2-elf-pkg-config).
 * O CMake nativo do Windows nao executa scripts sh ("inappropriate file type or format"),
 * entao o ps2sdk-ports falhava em find_package(PkgConfig).
 *
 * Faz o mesmo que o script:
 *   - zera PKG_CONFIG_DIR, PKG_CONFIG_PATH e PKG_CONFIG_SYSROOT_DIR (nada do host);
 *   - PKG_CONFIG_LIBDIR = ports, gsKit e ee/lib do PS2SDK;
 *   - chama pkg-config com --static (exceto em --version).
 *
 * PS2SDK/PS2DEV vem do ambiente; se ausentes, sao deduzidos da pasta deste .exe
 * (PS2SDK = ..\ , PS2DEV = ..\..\). O pkg-config usado e o que estiver ao lado
 * deste .exe (pkg-config.exe) ou, senao, o do PATH.
 *
 * Compilar (MSYS2 UCRT64): gcc -O2 -static -o mips64r5900el-ps2-elf-pkg-config.exe pkg-config-wrapper.c
 */
#include <process.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

#define MAX_ARGS 512

static char *quote(const char *arg)
{
    size_t len = strlen(arg);
    size_t i;
    char *out;
    char *p;
    int needs = (len == 0) || strpbrk(arg, " \t\"") != NULL;

    if (!needs)
        return _strdup(arg);

    out = malloc(len * 2 + 3);
    if (!out)
        return NULL;

    p = out;
    *p++ = '"';
    for (i = 0; i < len; i++) {
        if (arg[i] == '"')
            *p++ = '\\';
        *p++ = arg[i];
    }
    *p++ = '"';
    *p = '\0';

    return out;
}

int main(int argc, char **argv)
{
    char self[MAX_PATH];
    char sdk[MAX_PATH];
    char dev[MAX_PATH];
    char libdir[4 * MAX_PATH];
    char pkgconfig[MAX_PATH];
    const char *env_sdk = getenv("PS2SDK");
    const char *env_dev = getenv("PS2DEV");
    char *args[MAX_ARGS];
    char *slash;
    int n = 0;
    int i;

    GetModuleFileNameA(NULL, self, sizeof(self));

    /* ...\ps2sdk\bin\este.exe -> PS2SDK = ...\ps2sdk, PS2DEV = ... */
    snprintf(sdk, sizeof(sdk), "%s", self);
    if ((slash = strrchr(sdk, '\\')) != NULL) *slash = '\0';   /* bin    */
    if ((slash = strrchr(sdk, '\\')) != NULL) *slash = '\0';   /* ps2sdk */
    snprintf(dev, sizeof(dev), "%s", sdk);
    if ((slash = strrchr(dev, '\\')) != NULL) *slash = '\0';

    if (env_sdk && *env_sdk)
        snprintf(sdk, sizeof(sdk), "%s", env_sdk);
    if (env_dev && *env_dev)
        snprintf(dev, sizeof(dev), "%s", env_dev);

    snprintf(libdir, sizeof(libdir),
             "%s/ports/lib/pkgconfig;%s/gsKit/lib/pkgconfig;%s/ee/lib/pkgconfig",
             sdk, dev, sdk);

    _putenv("PKG_CONFIG_DIR=");
    _putenv("PKG_CONFIG_PATH=");
    _putenv("PKG_CONFIG_SYSROOT_DIR=");
    SetEnvironmentVariableA("PKG_CONFIG_LIBDIR", libdir);
    {
        static char buf[4 * MAX_PATH + 32];
        snprintf(buf, sizeof(buf), "PKG_CONFIG_LIBDIR=%s", libdir);
        _putenv(buf);
    }

    /* pkg-config.exe ao lado deste .exe (pacote portatil) ou no PATH */
    snprintf(pkgconfig, sizeof(pkgconfig), "%s", self);
    if ((slash = strrchr(pkgconfig, '\\')) != NULL)
        snprintf(slash + 1, sizeof(pkgconfig) - (size_t)(slash + 1 - pkgconfig), "pkg-config.exe");
    if (GetFileAttributesA(pkgconfig) == INVALID_FILE_ATTRIBUTES)
        snprintf(pkgconfig, sizeof(pkgconfig), "pkg-config");

    args[n++] = quote(pkgconfig);
    if (!(argc > 1 && strcmp(argv[1], "--version") == 0))
        args[n++] = _strdup("--static");
    for (i = 1; i < argc && n < MAX_ARGS - 1; i++)
        args[n++] = quote(argv[i]);
    args[n] = NULL;

    {
        intptr_t rc = _spawnvp(_P_WAIT, pkgconfig, (const char *const *)args);
        if (rc == -1) {
            fprintf(stderr, "pkg-config is not found\n");
            return 1;
        }
        return (int)rc;
    }
}
