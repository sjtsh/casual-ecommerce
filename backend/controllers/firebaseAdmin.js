var admin = require("firebase-admin");
var serviceAccount = {
  "type": "service_account",
  "project_id": "ezdelivery-a538c",
  "private_key_id": "1ec42073933132f16c7b3b85db6db23fe4248a84",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDKnZILugijfLsZ\nY63wLRa8qBvw49ARpLpZOtKKxuBcsXi0RdEKLZz8b0ntvqg+ExYevISANpfSdL3f\nCHRB2sNKGQLJ3kLyzyN15KzzJeyNSdZCSsUpLp6YLCpZS8/GSKjM4vn+rS8pnqu2\nPVK7sc+L49vwBbTDrEDZ1zZadTHa2GQebVEyUoV+gt8aDfK2mCO5/7T7sCMXwISp\nkPyDRWaoEdITqGVYvF5uXTkM2iIah0caKsHo78EYz8Y/5o51cM6D6YzS63QRuvaF\n5YBnsGXN+pr02rXzAprAfg5G8QAfSCV8bY7/dcbJ5I9MjlycoVLAyE9VPEGm4apS\nCkoedbLjAgMBAAECggEAC4EAzsukO+wUD2/6az2UIegFlhrJMIdC0Vgmphx+lqS4\n7rtcEBDg7fA/qVD+6m9Y/SvE9iajXh6kvSoUt7x9BBMBdoa5FGIwaDwwmamYkbkU\ngjUOlrT/6jHvwZwtUtvDQcbNXOlmWR2aMEGxFdkVqKKqVSltxwJbuEKg4mfvCbbP\nsEgJZnf3Nk7PyHEOuG/DvOXhn40TibOMoH9gxiNErbpgyaXi5X3Voiy8Zpaiown6\nVs9Aqxlo26x3hqtHqvCIlYqwDOJbOhTB0gxL1IUIISVhtNclGtcnyhxGMiyKq2Nh\nDhi7OXjfvoOSyzV8USZiOlzuGfGAi3wFy3QZygRPgQKBgQDrL5kgeYfiI/Yhq0d0\nYdx29UYZc86/hFPMWt/e+QwYJJwlW/taLl3/y61Cn2oMTw/+mu0l7JDNNIVEXt+2\nJEvEh/2lNW+4a3CLPnT1aW8ILTTk9Gnn/OyloSc2o01FUrqIPt9nqjnS8HyGPBD6\npcFCzaErTP6hvcjR14jlbAJxowKBgQDcjA2FhBEKiG/WmHp1snjtmZ1LoC/h1jjk\nVdi5ijiQApiFKAvyyOY9D6ObqOCf09EtVg7uUEzK82eG0rreN/NUjoNKO7FAMdDK\nKnejORZ1oGSlZ+yTwjGSPYmYPqk+jar19UM1sqfznbxuJQqXGh7rF1SEFXoz5cFz\nuXak4NBNwQKBgQCyqIjhc5D3CCx8rTltvr2UnIRw51mCgUqLLels37IBUSZQ9wv9\nGMYNgDMRLjqIOTNETXqjWY8yY5htNMkq+22XUVssumgxJ2TqUjrVBw/ynSzWVJlz\nQt6ef8pjJjCX3d2XjHN3s4eTp15hNpYLYglq7vxlAWtZgOtiBSKYbbF5kwKBgQCl\nwtnS1P0d5ofwSXAZEAfVxNQ1Z/M1ERZ3f5JBeYKjsl/CDORWGOr7T8rPDrGtTr10\nDq9wLIhbLXBNJAtxQ6oujmJdI9pH/mkH2b1Lv3eC9wdOTnrAX390g63r8ISx0DaD\nYFCghmO3NYHPYyW/hdFhLorGL4JGiVPJz8Y9i/7jwQKBgGFqUWlyDiIL29jikgre\nM2pyhv54E0DmOnLbblIwD9HfyDqSfxZog/DLHjdbjW++omDKcgipgoQbvolWdT06\niNVuUm46fa82BxzgYrglLNE2SzllAqmXZ7dEzVSIltS9nnJNtPGUsi/a9V7jIn66\nQDD1QgEdYJG+qVBi7JtP1ohm\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-zro2r@ezdelivery-a538c.iam.gserviceaccount.com",
  "client_id": "108678282035828894137",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-zro2r%40ezdelivery-a538c.iam.gserviceaccount.com"
}


admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});



module.exports = admin;