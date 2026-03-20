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

// Main function to run everything
async function main() {
  console.log("Starting upload...");
  try {
    await uploadStudents(grade5, "grade5");
    await uploadStudents(grade6, "grade6");
    await uploadStudents(grade7, "grade7");
    await uploadStudents(grade8, "grade8");
    console.log("All grades uploaded successfully!");
  } catch (error) {
    console.error("Upload failed:", error);
  }
}

main();