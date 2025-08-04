import * as rm from "https://deno.land/x/remapper@4.1.0/src/mod.ts"
import * as bundleInfo from './bundleinfo.json' with { type: 'json' }

const pipeline = await rm.createPipeline({ bundleInfo })

const bundle = rm.loadBundle(bundleInfo)
const materials = bundle.materials
const prefabs = bundle.prefabs

// ----------- { SCRIPT } -----------

async function doMap(file: rm.DIFFICULTY_NAME) {
    const map = await rm.readDifficultyV3(pipeline, file)

    rm.environmentRemoval(map, ['Environment', 'GameCore'])
    map.difficultyInfo.requirements = [
        'Chroma',
        'Noodle Extensions',
        'Vivify',
    ]

    map.difficultyInfo.settingsSetter = {
        graphics: {
            screenDisplacementEffectsEnabled: true,
        },
        chroma: {
            disableEnvironmentEnhancements: false,
        },
        playerOptions: {
            leftHanded: rm.BOOLEAN.False,
            noteJumpDurationTypeSettings: 'Dynamic',
        },
        colors: {},
        environments: {},
    }

    rm.setRenderingSettings(map, {
        qualitySettings: {
            realtimeReflectionProbes: rm.BOOLEAN.True,
            shadows: rm.SHADOWS.HardOnly,
            shadowDistance: 64,
            shadowResolution: rm.SHADOW_RESOLUTION.VeryHigh,
            
        },
        renderSettings: {
            fog: rm.BOOLEAN.True,
            fogEndDistance: 64,
        },
    })

    const sky = prefabs.sky.instantiate(map, 0)
    const cliff = prefabs.basecliff.instantiate(map, 0)
    const thunder = prefabs.thunder.instantiate(map, 0)
    const above = prefabs.above.instantiate(map, 0)

    // Example: Run code on every note!

    // map.allNotes.forEach(note => {
    //     console.log(note.beat)
    // })

    // For more help, read: https://github.com/Swifter1243/ReMapper/wiki
}

await Promise.all([
    doMap('ExpertPlusStandard')
])

// ----------- { OUTPUT } -----------

pipeline.export({
    outputDirectory: '../Rafae/'
})
