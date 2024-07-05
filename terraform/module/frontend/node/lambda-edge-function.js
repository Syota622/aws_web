const { Server } = require('http')
const { parse } = require('url')
const next = require('next')

const app = next({ dev: false })
const handle = app.getRequestHandler()

exports.handler = async (event, context) => {
  const request = event.Records[0].cf.request
  const { uri } = request
  
  await app.prepare()
  
  const server = new Server((req, res) => {
    req.url = uri
    handle(req, res)
  })
  
  return new Promise((resolve, reject) => {
    server.listen(0, (err) => {
      if (err) return reject(err)
      
      const { port } = server.address()
      
      const options = {
        hostname: 'localhost',
        port,
        path: uri,
        method: request.method,
        headers: request.headers,
      }
      
      const proxyReq = require('http').request(options, (proxyRes) => {
        let body = ''
        proxyRes.on('data', (chunk) => { body += chunk })
        proxyRes.on('end', () => {
          resolve({
            status: proxyRes.statusCode,
            headers: proxyRes.headers,
            body: body
          })
        })
      })
      
      proxyReq.on('error', reject)
      proxyReq.end()
    })
  })
}
