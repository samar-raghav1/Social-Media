import axios from 'axios';

const API = axios.create({ baseURL: process.env.VITE_APP_API_URL });


export const logIn = (formData) => API.post('/auth/login', formData); 

export const signUp = (formData) => API.post('/auth/register', formData);