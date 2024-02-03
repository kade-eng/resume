const {Firestore} = require('@google-cloud/firestore');
const firestore = new Firestore();

exports.visitCounter = async (req, res) => {
  const docRef = firestore.collection('visitors').doc('counter');
  await docRef.update({ count: Firestore.FieldValue.increment(1) });
  const doc = await docRef.get();
  res.status(200).send({ count: doc.data().count });
};
