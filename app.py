#!/usr/bin/env python3

# Import required modules
from flask import Flask, render_template, request, jsonify, url_for

# Initialize the application
app = Flask(__name__)

# Run the application
def run():
    app.run(host="127.0.0.1", debug=True)

# Home route of our app - it returns our homepage
@app.route("/", methods=["GET"])
def home():
    return render_template("index.html", title="Home")

@app.route("/register", methods=["GET"])
def register():
    return render_template("register.html", title="Register an account")

@app.route("/sign-in", methods=["GET"])
def sign_in():
    return render_template("sign-in.html", title="Sign in")

@app.route("/about", methods=["GET"])
def about():
    return render_template("about.html", title="About the project")

# 404 error handler
@app.errorhandler(404)
def page_not_found(e):
    # 404 - Page Not Found
    return render_template("404.html", title="404 Page Not Found", env="Page Not Found."), 404

# 500 error handler
@app.errorhandler(500)
def internal_server_error(e):
    # 500 - Internal Server Error
    return render_template("500.html", title="500 Internal Server Error", env="Internal Server Error"), 500

# Run the application
if __name__ == "__main__":
    run()