#!/usr/bin/env node
const {execSync}=require('child_process');

// Función auxiliar para extraer todas las temperaturas de una línea
function parseTemps(line){
    if(!line){
        return null;
    }

    const matches=line.match(/\+?\d+\.\d+°C/g);

    if(
        !matches||
        matches.length===0
    ){
        return null;
    }

    return {
        current:matches[0],
        high:matches[1]||'N/A',
        crit:matches[2]||'N/A'
    };
}

try{
    const output=execSync('sensors',{
        encoding:'utf-8'
        }),
        lines=output.split('\n');

    let ramCount=1,
        insideNvme=false;

    for(let i=0;i<lines.length;i++){
        const line=lines[i],
            trimmedLine=line.trim();

        // Detectar bloque NVMe
        if(line.startsWith('nvme-pci-0100')){
            insideNvme=true;

            continue;
        }

        // Apagar bloque NVMe al entrar a otro componente principal
        if(
            insideNvme&&
            (
                line.startsWith('acpitz-')||
                line.startsWith('spd5118-')||
                line.startsWith('coretemp-')||
                line.startsWith('iwlwifi_1-')
            )
        ){
            insideNvme=false;
        }

        // 1. Memoria RAM (spd5118)
        if(line.startsWith('spd5118-i2c-6-')){
            const nextLine=lines[i+2],
                temps=parseTemps(nextLine);

            if(temps){
                console.log(`\${voffset 4}ram ${ramCount}:`);
                console.log(`\${alignr 180}\${voffset -16}${temps.current}`);
                console.log('${alignr 100}${voffset -16}+55.0°C');
                console.log('${alignr 20}${voffset -16}+85.0°C');

                ramCount++;
            }
        }

        // 2. Procesamiento de NVMe (Por banderas de estado)
        if(insideNvme){
            if(trimmedLine.startsWith('Composite:')){
                const temps=parseTemps(line);

                if(temps){
                    console.log('${voffset 4}nvme 0:');
                    console.log(`\${alignr 180}\${voffset -16}${temps.current}`);
                    console.log('${alignr 100}${voffset -16}+89.8°C');
                    console.log('${alignr 20}${voffset -16}+94.8°C');
                }
            }

            if(trimmedLine.startsWith('Sensor 1:')){
                const temps=parseTemps(line);

                if(temps){
                    console.log('${voffset 4}nvme 1:');
                    console.log(`\${alignr 180}\${voffset -16}${temps.current}`);
                    console.log('${alignr 100}${voffset -16}');
                    console.log('${alignr 20}${voffset -16}');
                }
            }

            if(trimmedLine.startsWith('Sensor 2:')){
                const temps=parseTemps(line);

                if(temps){
                    console.log('${voffset 4}nvme 2:');
                    console.log(`\${alignr 180}\${voffset -16}${temps.current}`);
                    console.log('${alignr 100}${voffset -16}');
                    console.log('${alignr 20}${voffset -16}');
                }
            }
        }

        // 3. Placa Base ACPI (No tiene límites en tu salida)
        if(
            line.trim().startsWith('temp1:')&&
            lines[i - 2]?.startsWith('acpitz-acpi-0')
        ){
            const temps=parseTemps(line);

            if(temps){
                console.log('${voffset 4}acpi:');
                console.log(`\${alignr 180}\${voffset -16}${temps.current}`);
                console.log('${alignr 100}${voffset -16}');
                console.log('${alignr 20}${voffset -16}');
            }
        }

        // 4. Tarjeta Wi-Fi (No tiene límites en tu salida)
        if(
            line.trim().startsWith('temp1:')&&
            lines[i-2]?.startsWith('iwlwifi_1-virtual-0')
        ){
            const temps=parseTemps(line);

            if(temps){
                console.log('${voffset 4}wi-fi:');
                console.log(`\${alignr 180}\${voffset -16}${temps.current}`);
                console.log('${alignr 100}${voffset -16}');
                console.log('${alignr 20}${voffset -16}');
            }
        }

        // 5. CPU Package
        if(line.trim().startsWith('Package id 0:')){
            const temps=parseTemps(line);

            if(temps){
                console.log('${voffset 4}cpu:');
                console.log(`\${alignr 180}\${voffset -16}${temps.current}`);
                console.log(`\${alignr 100}\${voffset -16}${temps.high}`);
                console.log(`\${alignr 20}\${voffset -16}${temps.crit}`);
            }
        }

        // 6. CPU Núcleos (Cores)
        if(line.trim().startsWith('Core ')){
            const matchCore=line.match(/Core\s+(\d+):/),
                temps=parseTemps(line);

            if(
                matchCore&&
                temps
            ){
                const coreNum=matchCore[1].padStart(2, '0');

                console.log(`\${voffset 4}core ${coreNum}:`);
                console.log(`\${alignr 180}\${voffset -16}${temps.current}`);
                console.log(`\${alignr 100}\${voffset -16}${temps.high}`);
                console.log(`\${alignr 20}\${voffset -16}${temps.crit}`);
            }
        }
    }
}catch(error){
    console.error('sensors failure:', error.message);
}

