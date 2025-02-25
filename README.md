# GymTrack

**Track your progress, crush your goals.**

GymTrack is a **full-stack gym tracking application** that allows users to **log workouts, track progress, and visualize fitness insights**. Unlike other fitness apps that require a **subscription to access progress tracking**, GymTrack provides **free and detailed analytics** to help you stay on top of your fitness journey.

---

## 🚀 Features

✅ **Workout Logging** – Add exercises with sets, reps, and weights.
✅ **Progress Tracking** – View best lifts and analyze workout trends.
✅ **User Authentication** – Secure login system using JWT.
✅ **Responsive UI** – Cross-platform support with Flutter.
✅ **RESTful API** – Efficient and scalable backend using Spring Boot.
✅ **Data Insights** – Visualize weight progression and historical data.
✅ **Cloud Deployment Ready** – Built with scalability in mind.

---

## 🛠 Tech Stack

### **Backend**
- **Java 17+** – Primary programming language
- **Spring Boot** – Framework for building RESTful APIs
- **Spring Web** – API development
- **Spring Security & JWT** – Authentication & authorization
- **Spring Data JPA & Hibernate** – Database ORM
- **MySQL** – Relational database
- **Docker** – Containerization

### **Frontend**
- **Flutter** – Cross-platform UI framework
- **Dart** – Frontend language
- **Provider** – State management

### **DevOps & Hosting**
- **GitHub Actions** – CI/CD for automated deployments
- **AWS & Firebase Hosting** (Planned) – Scalable cloud hosting
- **Postman** – API testing and documentation

---

## 🎥 Walkthrough Video


https://github.com/user-attachments/assets/3f3d0109-ea2e-441b-ac88-71deb6dd38c3


---

## 🏗 Installation Guide

### **Backend Setup**
1. Clone the repository:
   ```bash
   git clone https://github.com/MajdIssa34/Gym-Tracking.git
   cd Gym-Tracking
   ```
2. Configure the database:
   - Update `application.properties` with your **MySQL credentials**.
3. Run the application:
   ```bash
   mvn spring-boot:run
   ```

### **Frontend Setup**
1. Navigate to the frontend folder:
   ```bash
   cd Gym-Tracking/frontend/my_gym_app
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

---

## 📌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|--------------|
| `POST` | `/api/auth/register` | Register a new user |
| `POST` | `/api/auth/login` | Authenticate user |
| `GET`  | `/api/workouts` | Fetch all workouts |
| `POST` | `/api/workouts` | Create a new workout |
| `GET`  | `/api/workouts/{id}` | Get workout details |
| `DELETE` | `/api/workouts/{id}` | Delete a workout |
| `GET` | `/api/progress/{userId}/{exerciseName}` | Fetch progress data |

More details in **Postman Documentation** *(Coming Soon!)*.

---

## 👨‍💻 Author

**Majd Issa**  
📧 Email: [issamajd00@gmail.com](mailto:issamajd00@gmail.com)  
🔗 LinkedIn: [Majd Issa](https://www.linkedin.com/in/majd-issa34)  
🖥 GitHub: [MajdIssa34](https://github.com/MajdIssa34)  
🌍 Website: [majdissa.net](https://majdissa.net)  

---

### ⭐ If you found this project useful, consider giving it a **star** on GitHub!

