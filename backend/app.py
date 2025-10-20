from flask import Flask, jsonify
app = Flask(__name__)

@app.route('/')
def home():
    return "<h2>Welcome to Wayline infratech Backend API</h2>"

@app.route('/about')
def about():
    return jsonify({
        "company":"Wayline Infratech",
        "description":"We provide professional road marking services and supply a range of road safety products across India."
    })
    
@app.route('/services')
def services():
    return jsonify({
        "Services":[
            "Thermoplastic Road Marking",
            "Traffic Sign Board",
            "Road Studs & Reflectrs",
            "Safety Cones &  Barriers"
        ]
    })
    
@app.route('/contact')
def contact():
    return jsonify({
        "E-mail":"info.waylineinfratech@gmail.com",
        "Phone":"+91 7028620586",
        "Address":"Faiz Nagar, Kalamb Road, Yavatmal-445001 (M.S)"
    })
    
@app.route('/health')
def health():
    return jsonify({"Status":"Healthy"}),200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)