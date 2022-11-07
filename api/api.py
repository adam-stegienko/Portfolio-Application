#!/usr/bin/env python3

# Import required modules
from flask import Flask, render_template, redirect, request, flash, session
from werkzeug.security import generate_password_hash, check_password_hash
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, logout_user, current_user
from flask_wtf import FlaskForm
from wtforms import StringField, EmailField, PasswordField, SubmitField
from wtforms.validators import DataRequired
from functools import wraps
from dotenv import load_dotenv
import os

# Initialize the application
app = Flask(__name__)

# Load the database environment variables
load_dotenv('../.env')
PROTOCOL = os.getenv('PROTOCOL')
MSSQL_USER = os.getenv('MSSQL_USER')
MSSQL_PASSWORD = os.getenv('MSSQL_PASSWORD')
MSSQL_SERVER = os.getenv('MSSQL_SERVER')
MSSQL_DB = os.getenv('MSSQL_DB')
DRIVER = os.getenv('DRIVER')
DB_PORT_OUT = os.getenv('DB_PORT_OUT')
OPTIONS = os.getenv('OPTIONS')

# Configure MS SQL Server database connection
app.config['SECRET_KEY'] = "I love DevOps"
app.config['WTF_CSRF_SECRET_KEY'] = "DevOps loves security"
app.config['SQLALCHEMY_DATABASE_URI'] = f"{PROTOCOL}://{MSSQL_USER}:{MSSQL_PASSWORD}@{MSSQL_SERVER}/{MSSQL_DB}?driver={DRIVER}&port={DB_PORT_OUT}&odbc_options={OPTIONS}"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Run the application
def run():
    app.run(host="0.0.0.0")

# Add 'Users' table
class Users(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key = True)
    username = db.Column(db.String(255))
    email = db.Column(db.String(255))
    password = db.Column(db.String)

    def __repr__(self):
        return f'User{self.username}{self.email}'

# Add 'Projects' table
class Projects(db.Model):
    project_id = db.Column(db.Integer, primary_key=True)
    project_name = db.Column(db.String(255))
    active = db.Column(db.Boolean)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))

    def __init__(self, project, user_id, active):
        self.project_name = project
        self.active = active
        self.user_id = user_id

    def __repr__(self):
        return '<Project {}>'.format(self.project_name)

# Add 'Tasks' table
class Tasks(db.Model):
    task_id = db.Column(db.Integer, primary_key=True)
    project_id = db.Column(db.Integer, db.ForeignKey('projects.project_id'))
    task = db.Column(db.Text)
    status = db.Column(db.Boolean, default=False)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))

    def __init__(self, project_id, task, user_id, status=True):
        self.project_id = project_id
        self.task = task
        self.status = status
        self.user_id = user_id

    def __repr__(self):
        return '<Task {}>'.format(self.task)

# Add 'Sign up' form
class RegisterForm(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    email = EmailField('Email', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Register')

# Add 'Sign in' form
class LoginForm(FlaskForm):
    username = StringField('User', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Sign In')

# Set the login manager
login_manager = LoginManager()
login_manager.init_app(app)

@login_manager.user_loader
def load_user(user_id):
    return Users.query.get(int(user_id))

# Initialize the database
with app.app_context():
    db.create_all()

# Define login requirement function
def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if session.get('username') is None or session.get('if_logged') is None:
            return redirect('/sign-in',code=302)
        return f(*args, **kwargs)
    return decorated_function

# Return homepage
@app.route("/", methods=["GET"])
def home():
    return render_template("index.html", title="Home")

# Return sign up page with registration form
@app.route("/sign-up", methods=['POST','GET'])
def sign_up():
    form = RegisterForm()
    if request.method == 'GET':
        return render_template("sign_up.html", title="Register an account", form=form)

    if request.method == "POST":
        username = request.form['username']
        password = request.form['password']

        if not (username and password):
            flash("Username or Password cannot be empty")
            return redirect('/sign-up')
        else:
            username = username.strip()
            password = password.strip()

        # Return salted pwd hash in format : method$salt$hashedvalue
        hashed_pwd = generate_password_hash(password, 'sha256')

        new_user = Users(username=username, password=hashed_pwd)
        db.session.add(new_user)

        try:
            db.session.commit()
        except SQLAlchemy.exc.IntegrityError:
            flash("Username {u} is not available.".format(u=username))
            return redirect('/sign-up')
        flash("User account has been created.")
        return render_template("sign_up.html", title="Register an account", form=form)

# Return sign in page with login form
@app.route("/sign-in", methods = ['POST','GET'])
def sign_in():
    form = LoginForm()
    if request.method == 'GET':
        return render_template('sign_in.html', title="Login to start using the planner", form=form)
    
    if request.method == 'POST':
        if form.validate_on_submit:
            user = Users.query.filter_by(username = form.username.data).first()
            if user and check_password_hash(user.password, form.password.data):
                login_user(user)
                return redirect('/planner')
            else:
                flash("Invalid username or password.")
                return redirect("/")

# Make the current session user log out and redirect to homepage
@app.route("/sign-out", methods=['POST','GET'])
def logout():
    logout_user()
    return redirect("/")

# Return about page with application overview
@app.route("/about", methods=["GET"])
def about():
    return render_template("about.html", title="About the project")

# Return planner page
@app.route("/planner", methods=["GET", "POST"])
def planner():
    if current_user.is_authenticated:
        active = None
        projects = Projects.query.filter_by(user_id=current_user.id).all()
        tasks = Tasks.query.filter_by(user_id=current_user.id).all()

        if len(projects) == 1:
            projects[0].active = True
            active = projects[0].project_id
            db.session.commit()

        if projects:
            for project in projects:
                if project.active:
                    active = project.project_id
            if not active:
                projects[0].active = True
                active = projects[0].project_id
        else:
            projects = None

        if projects:
            return render_template('planner.html', title="Planner", tasks=tasks, projects=projects, active=active)
        else:
            return render_template('planner.html', title="Planner", tasks=tasks, active=active)
    else:
        flash("Failed.")
        return redirect("/")

# Add a project and/or task to the planner
@app.route('/planner/add', methods=['POST'])
def add_task():
    found = False
    project_id = None
    task = request.form['task']
    project = request.form['project']
    
    if not task:
        return redirect('/planner')

    if not project:
        project = 'Tasks'

    projects = Projects.query.all()

    for proj in projects:
        if proj.project_name == project:
            found = True

    # Add the project if not in database already
    if not found:
        add_project = Projects(project, current_user.id, True)
        db.session.add(add_project)
        db.session.commit()
        projects = Projects.query.all()

    # Set the active tab
    for proj in projects:
        if proj.project_name == project:
            project_id = proj.project_id
            proj.active = True
        else:
            proj.active = False

    status = bool(int(request.form['status']))

    # Add the new task
    new_task = Tasks(project_id, task, current_user.id, status)
    db.session.add(new_task)
    db.session.commit()
    return redirect('/planner')

# Close task
@app.route('/planner/close/<int:task_id>')
def close_task(task_id):
    task = Tasks.query.get(task_id)

    if not task:
        return redirect('/planner')

    if task.status:
        task.status = False
    else:
        task.status = True

    db.session.commit()
    return redirect('/planner')

# Delete task
@app.route('/planner/delete/<int:task_id>')
def delete_task(task_id):
    task = Tasks.query.get(task_id)

    if not task:
        return redirect('/planner')

    db.session.delete(task)
    db.session.commit()
    return redirect('/planner')

# Delete all projects and tasks
@app.route('/planner/clear/<delete_id>')
def clear_all(delete_id):
    Tasks.query.filter(Tasks.project_id == delete_id).delete()
    Projects.query.filter(Projects.project_id == delete_id).delete()
    db.session.commit()

    return redirect('/planner')

# Delete all tasks
@app.route('/planner/remove/<lists_id>')
def remove_all(lists_id):
    Tasks.query.filter(Tasks.project_id == lists_id).delete()
    db.session.commit()

    return redirect('/planner')

# Move between project tabs
@app.route('/planner/project/<tab>')
def tab_nav(tab):
    projects = Projects.query.all()

    for project in projects:
        if project.project_name == tab:
            project.active = True
        else:
            project.active = False

    db.session.commit()
    return redirect('/planner')

# Run the application
if __name__ == "__main__":
    run()