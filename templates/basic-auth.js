'use strict';
exports.handler = (event, context, callback) => {
    const s = event.Records[0].cf.request
    const i = s.headers
    const n = new Buffer("".concat("${user}",":").concat("${password}")).toString("base64")
    const o = "Basic ".concat(n)
    if(void 0 !== i.authorization && i.authorization[0].value == o) {
        callback(null, s)
    } else{
        callback(null, {
            status: "401",
            statusDescription: "Unauthorized",
            body: "Unauthorized",
            headers:{
                "www-authenticate": [
                    {key: "WWW-Authenticate",value: "Basic"}
                ]
            }
        })
    }
};
