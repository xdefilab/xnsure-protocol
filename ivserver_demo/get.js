var app = express();
app.route("/api")
　　.get(jsonParser, (req, res) => {
　　　　//do something
　　　　const content = 'OK'
　　　　res.set({'Access-Control-Allow-Origin': 'http://127.0.0.1:3000'})
　　　　　　.send(content)

　　})