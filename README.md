# 🚀 Simple ngrok

[![macOS](https://img.shields.io/badge/macOS-10.15+-blue.svg)](https://www.apple.com/macos/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![ngrok](https://img.shields.io/badge/ngrok-compatible-orange.svg)](https://ngrok.com)

**The easiest way to set up ngrok tunnels on macOS.** Just double-click and go!

A standalone Mac application that provides an interactive, user-friendly interface for creating ngrok tunnels for any local development project. No terminal commands to remember, no configuration files to edit.

![Simple ngrok Demo](https://via.placeholder.com/600x400/0066cc/ffffff?text=Simple+ngrok+Demo)

## ✨ Features

- 🖱️ **One-click setup** - Just double-click the app
- 🎯 **Universal compatibility** - Works with any local development setup
- 💬 **Interactive prompts** - Guides you through configuration
- ✅ **Input validation** - Ensures valid URLs and ports
- 🛡️ **Safe execution** - No accidental commands or misconfigurations
- 📱 **Professional interface** - Clean terminal presentation
- 🔄 **Reusable** - Perfect for multiple projects and team sharing

## 🎬 Demo

When you double-click the app, it opens Terminal and provides this experience:

```
🚀 Simple ngrok - Universal Tunnel Setup
=========================================

Simple ngrok - Tunnel Configuration
===================================

Common local development URLs:
  • localhost (for most dev servers)
  • mysite.local (Local by Flywheel, MAMP, etc.)
  • site.test (Valet, Laravel Homestead)
  • 127.0.0.1 (IP address)

Enter your local site URL: localhost

Common development ports:
  • 80 (Apache, Nginx, WordPress)
  • 3000 (React, Node.js, Rails)
  • 8000 (Django, Python)
  • 8080 (Alternative HTTP)
  • 5173 (Vite)
  • 4200 (Angular)

Enter your local port [default: 80]: 3000

Enter project name [default: 'Local Development']: My React App

Configuration Summary:
  Project: My React App
  Local URL: localhost
  Local Port: 3000

[INFO] ngrok tunnel started successfully!
Local Site: localhost:3000
Public URL: https://abc123.ngrok-free.app

Your local site is now accessible at:
  🌐 https://abc123.ngrok-free.app
```

## 🚀 Quick Start

### Prerequisites

1. **macOS 10.15+** (Catalina or later)
2. **ngrok installed** - [Download from ngrok.com](https://ngrok.com/download) or install via Homebrew:
   ```bash
   brew install ngrok
   ```
3. **ngrok authenticated** - Sign up at [ngrok.com](https://ngrok.com) and run:
   ```bash
   ngrok authtoken YOUR_AUTH_TOKEN
   ```

### Installation

#### Option 1: Download Release (Recommended)

1. **Download** the latest `Simple ngrok.app` from [Releases](../../releases)
2. **Move** the app to your Desktop or Applications folder
3. **Double-click** to run!

#### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/yourusername/simple-ngrok.git
cd simple-ngrok

# Build the Mac app
./scripts/build-app.sh

# The app will be created in the build/ directory
```

_Note: On first run, macOS may ask for permission to run the app. Click "Open" to proceed._

## 🛠️ Usage Examples

### Web Development Scenarios

**React/Node.js Project:**

- Local URL: `localhost`
- Port: `3000`
- Perfect for testing API integrations and mobile devices

**WordPress Site (Local by Flywheel):**

- Local URL: `mysite.local`
- Port: `80`
- Great for testing plugins and themes with external services

**Django Development:**

- Local URL: `localhost`
- Port: `8000`
- Ideal for webhook testing and API development

### Real-World Use Cases

**🔐 OAuth Testing**
Test GitHub, Google, or other OAuth integrations by using the ngrok URL as your callback URL.

**🪝 Webhook Development**
Receive webhooks from Stripe, PayPal, or other services directly to your local development environment.

**📱 Mobile Testing**
Share your local development with team members or test on real mobile devices.

**👥 Client Demos**
Quickly share work-in-progress with clients or stakeholders.

## 🎯 Supported Development Environments

| Framework/Platform            | Typical URL | Common Ports     | Notes                     |
| ----------------------------- | ----------- | ---------------- | ------------------------- |
| React, Vue, Angular           | `localhost` | 3000, 4200, 5173 | Most modern JS frameworks |
| WordPress (Local by Flywheel) | `*.local`   | 80, 443          | Custom local domains      |
| Django, Flask                 | `localhost` | 8000, 5000       | Python web frameworks     |
| Ruby on Rails                 | `localhost` | 3000             | Ruby web framework        |
| PHP (XAMPP, MAMP)             | `localhost` | 80, 8080         | Traditional PHP setups    |
| Node.js/Express               | `localhost` | 3000, 8000       | Backend API development   |

## 🔧 Development

### Repository Structure

```
simple-ngrok/
├── src/
│   └── simple-ngrok.sh          # Main interactive script
├── scripts/
│   └── build-app.sh             # Build script for Mac app
├── build/                       # Generated files (git ignored)
├── README.md                    # This file
├── LICENSE                      # MIT license
└── .gitignore                   # Git ignore rules
```

### Building

To build the Mac app from source:

```bash
# Make sure you're in the project root
./scripts/build-app.sh

# The app will be created in build/Simple ngrok.app
```

### Testing

Test the script directly:

```bash
# Run the script directly
./src/simple-ngrok.sh

# Test with arguments
./src/simple-ngrok.sh --url localhost --port 3000 --name "Test Project"
```

## 🌟 Benefits

### For Developers

- **No command memorization** - Interactive prompts guide you
- **Works with any project** - Universal compatibility
- **Error prevention** - Input validation prevents mistakes
- **Time saving** - Quick setup without documentation lookup

### For Teams

- **Easy sharing** - Send the app file to team members
- **Consistent experience** - Same interface for everyone
- **Onboarding friendly** - New developers can use it immediately
- **Cross-project** - One tool for all development environments

## 🤝 Contributing

Contributions are welcome! Feel free to:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Setup

```bash
# Clone your fork
git clone https://github.com/yourusername/simple-ngrok.git
cd simple-ngrok

# Create a feature branch
git checkout -b my-new-feature

# Make your changes to src/simple-ngrok.sh

# Test your changes
./src/simple-ngrok.sh

# Build the app to test
./scripts/build-app.sh
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [ngrok](https://ngrok.com) for providing the tunneling service
- Apple for AppleScript and macOS automation capabilities
- The development community for inspiration and feedback

## 📞 Support

- 🐛 **Issues**: [GitHub Issues](../../issues)
- 💡 **Feature Requests**: [GitHub Discussions](../../discussions)
- 📚 **Documentation**: This README and inline help
- ⭐ **Star this repo** if you find it helpful!

---

**Made with ❤️ for developers who want simple, reliable ngrok tunneling on macOS.**
