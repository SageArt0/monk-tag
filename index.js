const core = require('@actions/core');
const exec = require('@actions/exec');

async function run() {
    try {
        const tagType = core.getInput('tag-type');
        const versionType= core.getInput('version-value');
        const src = __dirname;

        await exec.exec(`${src}/tag_update.sh -v ${tagType}.${versionType}`);
    } catch(error) {
        core.setFailed(error.message);
    }
}

run();