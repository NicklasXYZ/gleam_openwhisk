/**
 * "Hello" OpenWhisk action (serverless function) 
 */
function main({name}) {
    var msg = 'You did not tell me who you are...';
    if (name) {
        msg = `Hello ${name}!`
    }
    return {body: `<html><body><h3>${msg}</h3></body></html>`}
}