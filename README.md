# 🚀 Catalog Copilot — Flutter × Algolia

**Catalog Copilot** is a web-based product discovery experience built with Flutter Web and Algolia as part of the Algolia Agent Studio Challenge.

The project focuses on delivering a **consumer-facing, non-conversational copilot** that improves product search through relevance tuning, structured data, and low-latency retrieval — without relying on chat-based interactions.

🔗 **Live Demo:**  
https://algolia-agent-challenge.web.app

---

## ✨ Key Features

- 🔍 Fast product search powered by Algolia  
- 🧠 Copilot-style insights without conversational UI  
- ⚡ Low-latency search experience  
- 🏷 Quality Score (QS) visualization  
- 📊 Product detail view with contextual signals  
- 🎯 Search-driven UX focused on decision support  
- 🌐 Built with Flutter Web  

---

## 🧠 Concept

Catalog Copilot acts as a **silent assistant** that enhances product discovery by:

- prioritizing relevant results  
- surfacing product quality signals  
- reducing search friction  
- guiding user decisions in context  

Unlike chat-based assistants, this approach keeps users **in flow** while relevance does the heavy lifting.

---

## 🛠 Tech Stack

- **Flutter Web**
- **Dart**
- **Algolia Search**
  - Indexing
  - Searchable attributes
  - Relevance tuning
- **Dio** (HTTP client)
- **GoRouter** (navigation)
- **dart-define** (secure environment config)

---

## 🏗 Architecture Highlights

- Clean separation between UI and search layer  
- Search service abstraction for Algolia  
- Typed product model with Freezed  
- Responsive layout with reusable UI components  
- Production-ready environment configuration  

---

## 📦 Getting Started
## 🔐 Environment Variables

This project uses `flutter_dotenv`.

```bash
cp .env.example .env
flutter pub get

### 1️⃣ Clone the repository

```bash
git clone <your-repo-url>
cd flutter_challenge
