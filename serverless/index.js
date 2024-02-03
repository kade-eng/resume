const {Firestore} = require('@google-cloud/firestore');
const firestore = new Firestore();

exports.visitCounter = async (req, res) => {
  const docRef = firestore.collection('visitors').doc('counter');
  switch (req.method) {
    case 'GET':
      const doc = await docRef.get();
      res.status(200).send({ count: doc.data().count });
      break;
    case 'POST':
      await docRef.update({ count: Firestore.FieldValue.increment(1) });
      res.status(200).send('Counter incremented.');
      break;
    default:
      res.status(405).send({ error: 'Only GET and POST methods are allowed' });
      break;
  }
};
