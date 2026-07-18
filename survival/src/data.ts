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
        tools: ["hammerstone"],
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

const humanCaloriesPerDay = 3000;
const population = 1000;

export const society = {
    population: population,
    caloriesPerYear: population * humanCaloriesPerDay * 365,
};
