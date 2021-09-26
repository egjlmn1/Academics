import 'package:academics/reports/report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../cloud/firebaseUtils.dart';

Future<void> sendReport(Report report) async {
  List<DocumentSnapshot> docs = (await FirebaseFirestore.instance.collection(Collections.reports).where('post', isEqualTo: report.post).where('reason', isEqualTo: report.reason).get()).docs;
  if (docs.isEmpty) {
    return uploadObject(Collections.reports, report.toJson());
  } else {
    return updateObject(Collections.reports, docs[0].id, 'amount', FieldValue.increment(1));
  }
}

Future<List<Report>> getReports() async {
  List<DocumentSnapshot> docs = await getDocs(Collections.reports);
  return List<Report>.from(docs.map((doc) => decodeReport(doc)));
}

Report decodeReport(DocumentSnapshot doc) {
  Report report = Report.fromJson(doc.data());
  report.id = doc.id;
  return report;
}