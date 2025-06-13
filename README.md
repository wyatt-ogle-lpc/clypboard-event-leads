# Clypboard Event Leads Web App

A full-stack web application built to streamline lead capture, validation, and routing at expos and trade shows for pest control companies.

## 🥉 Features

- Mobile-optimized landing page for live lead entry
- Captures: `Name`, `Phone`, `Email`, `Address`, `Pest Type`, `Expo Name`, `Company`
- Address validation via **Google Maps API**
- Email quality scoring with **ZeroBounce API**
- Company context enrichment using **OpenAI API + SerpAPI**
- “Catch the Termite” mini-game to increase engagement
- Raffle system with duplicate filtering
- Structured lead storage for post-event processing

## ⚙️ Stack

- **Backend:** Ruby on Rails  
- **Frontend:** HTML, CSS, JavaScript  
- **Database:** PostgreSQL  
- **Background Jobs:** Sidekiq  
- **Asset Pipeline:** Propshaft  
- **Deployment:** DigitalOcean (Puma server)

## 🔌 APIs Used

| API           | Purpose                                 |
|---------------|-----------------------------------------|
| Google Maps   | Address validation & geocoding          |
| ZeroBounce    | Email verification and scoring          |
| OpenAI API    | Company summary generation              |
| SerpAPI       | Business details for enrichment         |

## 🛠️ Setup Instructions

1. **Clone the repo:**
   ```bash
   git clone https://github.com/your-org/clypboard-event-leads.git
   cd clypboard-event-leads
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   yarn install
   ```

3. **Set up environment variables:**
   Create a `.env` file and define:

   ```
   GOOGLE_MAPS_API_KEY=your_key_here
   ZERBOUNCE_API_KEY=your_key_here
   OPENAI_API_KEY=your_key_here
   SERPAPI_KEY=your_key_here
   ```

4. **Set up the database:**
   ```bash
   rails db:create db:migrate
   ```

5. **Run the server:**
   ```bash
   rails server
   ```

6. **Start Sidekiq:**
   ```bash
   bundle exec sidekiq
   ```

## 📋 Post-Trade Show Scripts

After each event, the following maintenance scripts are run to enrich and clean the new lead data:

- **Automatic BDM Assignment**  
  Assigns leads to the correct Business Development Manager using spatial territory matching (PostGIS)

- **Duplicate Location Matching**  
  Geocodes new leads and matches to existing customers via Google Place IDs

- **Lead Source Assignment**  
  Tags each lead with the corresponding expo for ROI reporting

These scripts ensure clean data routing and reduce manual overhead for the sales team.

## 🛠️ Deploying to Production (DigitalOcean)

1. SSH into your droplet
2. Navigate to your app directory:
   ```bash
   cd /path/to/your/app
   ```
3. Pull the latest code and apply updates:
   ```bash
   git pull origin main
   bundle install
   RAILS_ENV=production bundle exec rails db:migrate
   RAILS_ENV=production bundle exec rails assets:precompile
   sudo systemctl restart clypboard-puma
   sudo systemctl status clypboard-puma
   ```

4. Restart background jobs if needed:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable sidekiq
   sudo systemctl start sidekiq
   sudo systemctl status sidekiq
   ```

## 🔐 API Keys and Credentials

To edit Rails credentials securely:
```bash
EDITOR="nano" bin/rails credentials:edit
```

## 🛠️ Developer Tips (Optional)

Generate a new migration:
```bash
rails generate migration AddFieldToModel field:type
```

Standard Git workflow:
```bash
git status
git add .
git commit -m "Your message"
git push origin main
```

## 📁 File Structure Overview

```
app/
├── controllers/
├── models/
├── views/
├── jobs/               # Background tasks (e.g., enrichment, validation)
├── services/           # External API wrappers (OpenAI, Google, etc.)
config/
lib/
public/
```

## 👥 Contributors

- Wyatt Ogle – Developer  
- Lloyd Pest Control – Client Organization

## 📬 Questions?

Feel free to reach out for implementation details or adaptation suggestions:  
**wyatt.ogle@lloydpest.com**
