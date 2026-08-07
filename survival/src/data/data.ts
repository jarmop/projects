type Resource = {
    name: string;
};

type Material = Resource | Product;

type Product = {
    name: string;
    materials: Material["name"][];
    tools: Product["name"][];
    description: string;
    category: string;
};

export const products: Product[] = [
    {
        name: "knife",
        materials: ["flint"],
        tools: ["hammerstone"], // deduced from the material
        description: "",
        category: "tool",
    },
    {
        name: "spear",
        materials: ["wood"],
        tools: ["knife, fire"],
        description: "",
        category: "tool",
    },
    {
        name: "axe",
        materials: ["flint, wood, cordage"],
        tools: ["hammerstone, knife"],
        description: "",
        category: "tool",
    },
    {
        name: "dried meat",
        materials: ["meat"],
        tools: ["fire"],
        description: "",
        category: "food",
    },
    {
        name: "meat",
        materials: ["carcass"],
        tools: ["knife"],
        description: "",
        category: "food",
    },
    {
        name: "carcass",
        materials: ["animal"],
        tools: ["spear"],
        description: "",
        category: "food",
    },
    {
        name: "house",
        materials: ["Foundation", "Frame", "Roof", "Floor"],
        tools: ["axe"],
        description: "",
        category: "housing",
    },
];

export const processes = [
    {
        name: "hunt",
        animals: ["deer", "boar"],
        tool: "spear",
        product: "carcass",
        efficiency: 1,
    },
    {
        name: "hunt",
        animals: ["deer", "boar"],
        tools: ["bow"],
        product: "carcass",
        efficiency: 2,
    },
];

export const animals = [
    {
        name: "deer",
        material: [
            { name: "meat", amount: 65 },
            { name: "fat", amount: 10 },
            { name: "bones", amount: 30 },
        ],
    },
];
