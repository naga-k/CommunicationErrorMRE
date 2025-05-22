import express from 'express';
import path from 'path';
const app = express();
app.use(express.static(path.join(__dirname,'public')));
app.listen(3005,()=>console.log('Editor @ http://localhost:3005'));
