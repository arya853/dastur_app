const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Import your JSON files
const grade5 = require("./tableConvert.com_grade5.json");
const grade6 = require("./tableConvert.com_grade6.json");
const grade7 = require("./tableConvert.com_grade7.json");
const grade8 = require("./tableConvert.com_grade8.json");

// Function to upload students
async function uploadStudents(data, grade) {

  for (const student of data) {

    await db
      .collection("students")
      .doc(grade)
      .collection("list")
      .doc(student["GR NO."])
      .set(student);

    console.log("Uploaded:", student["GR NO."]);
  }

}

// Upload each grade
uploadStudents(grade5, "grade5");
uploadStudents(grade6, "grade6");
uploadStudents(grade7, "grade7");
uploadStudents(grade8, "grade8");