#!/usr/bin/env node
const {execSync}=require('child_process');

// 1. LISTA DE OMISIÓN: Nombres de servicios que deseas ocultar (sin .service)
const SERVICIOS_A_OMITIR=new Set([
    // --- Alias y Subservicios Duplicados de D-Bus ---
    'dbus-org.freedesktop.hostname1',
    'dbus-org.freedesktop.locale1',
    'dbus-org.freedesktop.login1',
    'dbus-org.freedesktop.machine1',
    'dbus-org.freedesktop.network1',
    'dbus-org.freedesktop.nm-dispatcher',
    'dbus-org.freedesktop.portable1',
    'dbus-org.freedesktop.resolve1',
    'dbus-org.freedesktop.timedate1',
    'dbus-org.freedesktop.timesync1',

    // --- Puntos de Interrupción y Dracut (Arranque) ---
    'breakpoint-pre-basic',
    'breakpoint-pre-mount',
    'breakpoint-pre-switch-root',
    'breakpoint-pre-udev',
    'dracut-cmdline',
    'dracut-initqueue',
    'dracut-mount',
    'dracut-pre-mount',
    'dracut-pre-pivot',
    'dracut-pre-trigger',
    'dracut-pre-udev',
    'dracut-shutdown',
    'dracut-shutdown-onfailure',
    'initrd-cleanup',
    'initrd-parse-etc',
    'initrd-switch-root',
    'initrd-udevadm-cleanup-db',

    // --- Tareas Atómicas Internas de Systemd ---
    'systemd-ask-password-console',
    'systemd-ask-password-wall',
    'systemd-battery-check',
    'systemd-binfmt',
    'systemd-boot-check-no-failures',
    'systemd-confext',
    'systemd-confext-initrd',
    'systemd-confext-sysroot',
    'systemd-coredump-register',
    'systemd-coredumpd',
    'systemd-exit',
    'systemd-factory-reset-complete',
    'systemd-factory-reset-reboot',
    'systemd-factory-reset-request',
    'systemd-firstboot',
    'systemd-fsck-root',
    'systemd-growfs-root',
    'systemd-halt',
    'systemd-hibernate',
    'systemd-hibernate-clear',
    'systemd-hibernate-resume',
    'systemd-hostnamed',
    'systemd-hwdb-update',
    'systemd-hybrid-sleep',
    'systemd-journal-catalog-update',
    'systemd-journal-flush',
    'systemd-journald',
    'systemd-kexec',
    'systemd-localed',
    'systemd-logind',
    'systemd-machine-id-commit',
    'systemd-machined',
    'systemd-modules-load',
    'systemd-mountfsd',
    'systemd-network-generator',
    'systemd-networkd',
    'systemd-networkd-persistent-storage',
    'systemd-networkd-wait-online',
    'systemd-nsresourced',
    'systemd-oomd',
    'systemd-portabled',
    'systemd-poweroff',
    'systemd-pstore',
    'systemd-quotacheck-root',
    'systemd-random-seed',
    'systemd-reboot',
    'systemd-remount-fs',
    'systemd-repart',
    'systemd-resolved',
    'systemd-rfkill',
    'systemd-soft-reboot',
    'systemd-storagetm',
    'systemd-suspend',
    'systemd-suspend-then-hibernate',
    'systemd-sysctl',
    'systemd-sysext',
    'systemd-sysext-initrd',
    'systemd-sysext-sysroot',
    'systemd-sysinstall',
    'systemd-sysusers',
    'systemd-time-wait-sync',
    'systemd-timedated',
    'systemd-timesyncd',
    'systemd-tmpfiles-clean',
    'systemd-tmpfiles-setup',
    'systemd-tmpfiles-setup-dev',
    'systemd-tmpfiles-setup-dev-early',
    'systemd-udev-load-credentials',
    'systemd-udev-settle',
    'systemd-udev-trigger',
    'systemd-udevd',
    'systemd-update-done',
    'systemd-update-utmp',
    'systemd-user-sessions',
    'systemd-userdb-load-credentials',
    'systemd-userdbd',
    'systemd-vconsole-setup',
    'systemd-volatile-root',

    // --- Mantenimiento de Hardware y Sistemas de Archivos ---
    'e2scrub_all',
    'e2scrub_reap',
    'fstrim',
    'kmod-static-nodes',
    'ldconfig',
    'man-db',
    'quotaon-root',
    'system-update-cleanup',
    'xfs_healer_start',
    'xfs_scrub_all',
    'xfs_scrub_all_fail',

    // --- Redundancias de Configuración e Init ---
    'NetworkManager-config-initrd',
    'NetworkManager-dispatcher',
    'NetworkManager-initrd',
    'NetworkManager-wait-online',
    'NetworkManager-wait-online-initrd',
    'nm-cloud-setup',
    'nm-priv-helper',
    'ostree-boot-complete',
    'ostree-finalize-staged',
    'ostree-finalize-staged-hold',
    'ostree-prepare-root',
    'ostree-remount',

    // --- Tareas de Cierre y Entorno de Consola TTY ---
    'canberra-system-bootup',
    'canberra-system-shutdown',
    'canberra-system-shutdown-reboot',
    'console-getty',
    'debug-shell',
    'emergency',
    'pam_namespace',
    'rescue',
    'alsa-restore',
    'alsa-state',

    'flatpak-system-helper',
    'flatpak-update',

    'ip6tables-restore',
    'ip6tables-store',
    'iptables-restore',
    'iptables-store'
]);

// 2. Configuración de textos/estados para Conky
const PERSISTENCIA_ON='o';
const PERSISTENCIA_OFF='x';
const INICIADO_ON='o';   // El servicio está corriendo [1]
const INICIADO_OFF=' '; // El servicio está detenido [1]

try {
    // Comando 1: Leer archivos de unidad del disco (Habilitado/Deshabilitado)
    const rawFiles=execSync(
        'systemctl list-unit-files --type=service --no-legend',
        {
            encoding:'utf8'
        }
    );

    // Comando 2: Leer el estado en tiempo real (Cuáles están realmente corriendo) [1]
    const rawRunning=execSync(
        'systemctl list-units --type=service --state=running --no-legend',
        {
            encoding:'utf8'
        }
    );

    // Guardar en un Set todos los servicios que están activos actualmente para cruzar los datos rápidamente [1]
    const serviciosCorriendo=new Set();

    rawRunning
    .trim()
    .split('\n')
    .forEach((linea)=>{
        const partes=linea
        .trim()
        .split(/\s+/);

        if(partes[0]){
            serviciosCorriendo.add(partes[0].replace(/\.service$/,''));
        }
    });

    const lineasArchivos=rawFiles.trim().split('\n');
    const serviciosFormateados=[];

    for(const linea of lineasArchivos){
        const partes=linea.trim().split(/\s+/);

        if(partes.length<2){
            continue;
        }

        let servicio=partes[0].replace(/\.service$/, '');

        const tipoEstado=partes[1]; // enabled, disabled, static, etc.

        // Ignorar si el servicio está en la lista de omisión, vacío o contiene '@'
        if(
            SERVICIOS_A_OMITIR.has(servicio)||
            servicio===''||
            servicio.includes('@')
        ){
            continue;
        }

        // Determinar Columna 3: Persistencia (Arranque automático)
        const persistencia=(
            tipoEstado==='enabled'||
            tipoEstado==='generated'||
            tipoEstado==='static'
        )?
            PERSISTENCIA_ON:
            PERSISTENCIA_OFF;

        // Determinar Columna 2: ¿Está iniciado/corriendo ahora mismo? [1]
        const estaIniciado=serviciosCorriendo.has(servicio)?
            INICIADO_ON:
            INICIADO_OFF;

        // Almacenar datos para ordenar alfabéticamente
        // Usamos ${goto} y ${alignr} para que las columnas no se desalinien por el largo del texto
        serviciosFormateados
        .push({
            nombre:servicio,
            salidaConky:
                `\${voffset 4}${servicio}\n`+
                `\${alignr 30}\${voffset -16}${estaIniciado}\n`+
                `\${alignr 40}\${voffset -16}${persistencia}`
        });
    }

    // Ordenar alfabéticamente (A-Z) ignorando mayúsculas/minúsculas
    serviciosFormateados
    .sort((a,b)=>{
        return a.nombre.localeCompare(b.nombre,undefined,{
            sensitivity:'base'
        });
    })
    .forEach((item)=>{
        console.log(item.salidaConky);
    });
}catch(error){
    console.error('Error al consultar systemctl:',error.message);
    process.exit(1);
}

