#!/usr/bin/env node

let Vimeo = require('vimeo').Vimeo;
let client = new Vimeo("1592e1ea553f98ec81946ea2e14292ea42f1f77e", "fJjncOcHv5PtmvJJMqFFBgtq82crZB+UR9jla3Wj1YHL+Ucjw5BXvXMgrq4qEB08x1zHdoPmOiqiN9ILSz2wHQFnQgsmNKivaDuKfb1LzM0mpaBEBXcZgzpRCVtOkNWC", "bead71eb803fe422de031fdaee4c47ba");

client.request({
  method: 'GET',
  path: '/tutorial'
}, function (error, body, status_code, headers) {
  if (error) {
    console.log(error);
  }

  console.log(body);
})

