import fs from 'node:fs';
import path from 'node:path';

const inputDirectory = path.join(process.cwd(), 'public/assets/raw-images');
const outputFile = path.join(process.cwd(), 'src/data/imageDb.json');
const allowedExtensions = new Set(['.jpg', '.jpeg', '.png', '.webp']);

function generateDatabase() {
    if (!fs.existsSync(inputDirectory)) {
        console.error(`Создайте папку ${inputDirectory} и положите туда изображения.`);
        process.exitCode = 1;
        return;
    }
    const files = fs.readdirSync(inputDirectory).filter((file) => allowedExtensions.has(path.extname(file).toLowerCase()));
    const database = files.map((file, index) => ({
        id: `IMG-${1000 + index}`,
        title: path.parse(file).name.replace(/[-_]/g, ' '),
        category: ['architecture', 'graphics', 'texture', 'ui_tech'][index % 4],
        url: `/assets/raw-images/${file}`,
        metrics: { geo: 50, tex: 50, clr: 50, rhm: 50 },
        hex_palette: ['#111111', '#888888', '#EEEEEE']
    }));
    fs.mkdirSync(path.dirname(outputFile), { recursive: true });
    fs.writeFileSync(outputFile, `${JSON.stringify(database, null, 2)}\n`);
    console.log(`База данных собрана: ${database.length} объектов.`);
}

generateDatabase();
