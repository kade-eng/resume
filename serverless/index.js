const cors = require('cors')({origin: 'https://kade-bc.com'});
const {Firestore} = require('@google-cloud/firestore');
const firestore = new Firestore();

exports.visitCounter = (req, res) => {
  cors(req, res, async () => {
    const docRef = firestore.collection('visitors').doc('counter');
    await docRef.update({ count: Firestore.FieldValue.increment(1) });

    const doc = await docRef.get();
    res.status(200).send({ count: doc.data().count });
  });
};
