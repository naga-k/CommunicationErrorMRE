import express from 'express';
import cors from 'cors';
import path from 'path';
const app = express();
app.use(cors({ origin: 'http://localhost:5000', credentials: true }));
app.use((req, res, next) => {
  res.header('Content-Security-Policy',
    `default-src 'self'; frame-ancestors http://localhost:5000;`
  );
  next();
});
app.use(express.static(path.join(__dirname,'public')));
app.listen(3005,()=>console.log('Editor @ http://localhost:3005'));
