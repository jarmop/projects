import fs = require('fs');

class FileSystem {
    saveJson(data) {
        fs.writeFile('../json/soybean.json', JSON.stringify(data, null, 4), function(err) {
            if (err) throw err;
            console.log('JSON file saved!');
        });
    }
}
