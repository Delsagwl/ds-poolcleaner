Config = {}

Config.NPC = {
    x = -1320.97,
    y = -1263.16,
    z = 4.59,
    h = 286.56
}

Config.Furgoneta = {
    x = -1307.71,
    y = -1260.6,
    z = 4.07,
    h = 18.89,
    matricula = "9R75H01W",
}

Config.RecompensaMin = 30
Config.RecompensaMax = 70

Config.ZonasLimpieza = {
    ["Hotel"] = {
        vector3(-1354.32, 354.51, 64.08),
        vector3(-1345.54, 357.32, 64.08),
        vector3(-1339.37, 362.74, 64.08),
        vector3(-1323.72, 361.49, 64.08),
        vector3(-1314.81, 358.09, 64.08),
        vector3(-1315.17, 350.22, 64.08),
        vector3(-1324.81, 345.22, 64.08),
        vector3(-1329.66, 340.42, 64.08),
        vector3(-1339.15, 340.57, 64.08),
        vector3(-1347.51, 338.36, 64.08),
    },
    ["Casa1"] = {
        vector3(-1710.57, -457.62, 41.59),
        vector3(-1710.58, -462.01, 41.59),
        vector3(-1703.82, -462.06, 41.64),
        vector3(-1699.35, -465.06, 41.59),
        vector3(-1696.07, -467.61, 41.65),
        vector3(-1708.42, -458.53, 41.59),
        vector3(-1708.05, -468.11, 41.59),
        vector3(-1706.91, -477.80, 41.59),
        vector3(-1702.43, -475.64, 41.65),
        vector3(-1700.05, -471.45, 41.65),
    },
}

Config.Clothes = {
    male = {
        components = { {
                ["component_id"] = 0,
                ["texture"] = 0,
                ["drawable"] = 0
            }, {
                ["component_id"] = 1, -- Mask
                ["texture"] = 0,
                ["drawable"] = 0
            }, {
                ["component_id"] = 3, -- Upper Body
                ["texture"] = 0,
                ["drawable"] = 63
            }, {
                ["component_id"] = 4, -- Lower Body
                ["texture"] = 0,
                ["drawable"] = 129
            }, {
                ["component_id"] = 5, -- Bag
                ["texture"] = 0,
                ["drawable"] = 0
            }, {
                ["component_id"] = 6,-- Shoes
                ["texture"] = 0,
                ["drawable"] = 25
            }, {
                ["component_id"] = 7, -- Scarf & Chains
                ["texture"] = 0,
                ["drawable"] = 0
            }, {
                ["component_id"] = 8, -- Shirt
                ["texture"] = 0,
                ["drawable"] = 15
            }, {
                ["component_id"] = 9, -- Body Armor
                ["texture"] = 0,
                ["drawable"] = 0
            }, {
                ["component_id"] = 11, -- Jacket
                ["texture"] = 1,
                ["drawable"] = 241
            },
        },
    },
    female = {
        components = {
            {
                ["component_id"] = 0,
                ["texture"] = 0,
                ["drawable"] = 0
            }, {
                ["component_id"] = 1, -- Mask
                ["texture"] = 0,
                ["drawable"] = 0
            }, {
                ["component_id"] = 3, -- Upper Body
                ["texture"] = 0,
                ["drawable"] = 72
            }, {
                ["component_id"] = 4, -- Lower Body
                ["texture"] = 0,
                ["drawable"] = 135
            }, {
                ["component_id"] = 5, -- Bag
                ["texture"] = 0,
                ["drawable"] = 0
            }, {
                ["component_id"] = 6,-- Shoes
                ["texture"] = 0,
                ["drawable"] = 25
            }, {
                ["component_id"] = 7, -- Scarf & Chains
                ["texture"] = 0,
                ["drawable"] = 0
            }, {
                ["component_id"] = 8, -- Shirt
                ["texture"] = 0,
                ["drawable"] = 14
            }, {
                ["component_id"] = 9, -- Body Armor
                ["texture"] = 0,
                ["drawable"] = 0
            }, {
                ["component_id"] = 10,  -- Decals
                ["texture"] = 0,
                ["drawable"] = 0
            }, {
                ["component_id"] = 11, -- Jacket
                ["texture"] = 1,
                ["drawable"] = 250
            },
        },
    }
}
