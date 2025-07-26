# Revolut Home Task - Hello World API

A test Node.js API service built with Express.js, featuring comprehensive infrastructure as code, automated CI/CD and testing.

## Problem Statement & Design

### Overview
This project demonstrates a API service that follows modern DevOps practices and architecture principles.

### Architecture Design

#### Application Layer
- **Framework**: Express.js 5.x with ES modules
- **Language**: Node.js 22 (LTS)
- **Database**: SQLite
- **Containerization**: Docker with Alpine Linux base image
- **Health Checks**: Liveness and readiness probes for Kubernetes orchestration

#### Infrastructure Layer
- **Cloud Platform**: Google Cloud Platform (GCP)
- **Compute**: Cloud Run v2 (serverless containers)
- **Storage**: Google Cloud Storage for persistent SQLite database
- **Infrastructure as Code**: Terraform for provisioning and management

#### Design Decisions Justification

1. **Cloud Run over GKE over Compute VM**: 
   - Reduced operational overhead
   - Automatic scaling and load balancing
   - Fits in GCP free tier
   - Built-in security and networking

2. **SQLite with Cloud Storage**:
   - Simplified deployment (no external database dependencies)
   - Cost-effective for small to medium workloads, within GCP Free Tier
   - Easy backup and restore via GCS
   - Can be migrated to managed databases by change 1 code line

3. **Terraform for IaC**:
   - Declarative infrastructure management
   - Version-controlled infrastructure changes
   - Reproducible deployments across environments
   - Integration with GCP's native services

4. **Deployment Strategy**:
   - Zero-downtime deployments within Cloud Run
   - Easy rollback capabilities
   - Risk mitigation for production releases


Sidenotes:

1. Infrastructure defined in `infrastructure` folder should be separated from the application code base and managed separately by DevOps/ Cloud team. It was kept here to simplify things and not create different repositories. Infrastructure's state declared in that folder should be stored in remote backend which is not implemented in this project, it's currently managed just manually.

2. Migrations are declared in `src/migrations` folder. Each migration could contain either schema migration or data migration or both. Migration automatically applied whenever application starts. When application deployed having multiple replicas, db migrations will execute in every replica. For now in CLoud Run it would not be a problem because we don't have any traffic here. But in real life projects it could create problems. Therefore, there could be 2 potential options: a) separate migrations to cloud run job and execute job before rolling out the application (removes the concurency) b) implement migration table locking and in case of 2 or more concurrent replicas start applying migrations concurrently, one of them acquire lock, others will wait (concurrency control)

3. Database backups. Again, for simplification I have not implemented any process for backuping data. But, since we use Cloud storage as a eventual storage where SQLite db file is stored, we could add syncing to another backup bucket to keep separate copy. It could be done periodically again using cloud run. In real life, it's obviously would be different and backups could be made using daatabase read replica, to avoid any kind of load or influence on the database which used to serve real traffic. Also some backup capabilities are already enabled by cloud provider as point in time recovery or automatic backups.

## Local Setup & Development

### Prerequisites
- Node.js 22.x
- Docker
- Terraform 1.5.7+
- Google Cloud SDK (for deployment)

### Environment Variables
Create a `.env` file in the root directory based on `.env.example`:

```bash
PORT=3003
DB_DIALECT=sqlite
```

### Local Development Setup

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Run Database Migrations**
   ```bash
   npm run migrate
   ```

3. **Start Development Server**
   ```bash
   npm run dev
   ```

4. **Run Tests**
   ```bash
   npm test
   ```

### Docker Development

1. **Build Image**
   ```bash
   docker build -t revolut-hello-app .
   ```

2. **Run Container**
   ```bash
   docker run -p 3003:3003 revolut-hello-app
   ```

### Database Setup

#### SQLite
The application uses SQLite by default. The database file is automatically created on project startup.

## Code Quality & Architecture

### Project Structure
```
revolut-hometask/
├── src/
│   ├── config/         # Configuration management
│   ├── db/             # Database connection configuration
│   ├── modules/        # Feature modules
│   ├── migrations/     # Database migrations
│   ├── utils/          # Utility functions
│   ├── index.js        # Application entry point
│   └── routes.js       # Route definitions
├── tests/
│   ├── integration/    # Integration tests
│   └── setup.js        # Test configuration
├── bin/                # Executable scripts
├── infrastructure/     # Infrastructure declaration
├── .github/workflows/  # CI/CD pipelines
├── Dockerfile          # Container definition
├── terraform.tf        # Infrastructure as Code
└── package.json        # Dependencies and scripts
```

### Code Quality Features

1. **Modular Architecture**: Clean separation of concerns with feature-based modules
2. **Configuration Management**: Environment-based configuration with dotenv
3. **Input Validation**: Joi schema validation for API endpoints
4. **Error Handling**: Centralized error handling and graceful shutdown
5. **Database Migrations**: Umzug-based migration system
6. **Testing**: Jest with Supertest for integration testing
7. **Logging**: Structured logging with proper error tracking

### Package Management
- **Package Manager**: npm with lockfile for reproducible builds
- **Dependencies**: Production and development dependencies properly separated
- **Scripts**: Standardized npm scripts for common operations


#### Infrastructure Security
- **IAM Integration**: Google Cloud IAM for service authentication
- **Network Policies**: Cloud Run's built-in network security
- **Secret Management**: Environment variables for sensitive data
- **Access Control**: Public access controlled via IAM policies

### Database Strategy

#### Migrations
- **Migration Tool**: Umzug for database schema management
- **Version Control**: Migrations tracked in version control
- **Rollback Support**: Downward migrations for schema rollbacks

#### Backup Strategy
- **Automated Backups**: GCS-based backup for SQLite databases
- **Point-in-Time Recovery**: Database snapshots via Cloud Storage
- **Cross-Region Replication**: GCS multi-region storage for disaster recovery

#### Replication (Future Enhancement)
- **Read Replicas**: Can be implemented with managed database services
- **Failover**: Automatic failover with Cloud SQL or similar services

## CI/CD & Automation

### Continuous Integration

#### Pull Request Pipeline (`.github/workflows/verify.yaml`)

`verify.yaml` file implements very simple pull request pipeline that just runs application tests which blocks merging if tests fail. This pipeline obviously could be unlimitedly extended by adding linting, code coverage amnd many many more things

### Continuous Deployment

`deploy.yaml` file implements build & deployment of test application to GCP. In real life projects the strategy may differ a lot. Some projects would not want to have automatic deployments on any environment. On the other hand there are many examples when project demands continious delivery on production, which means deployment right after code lands to main branch. This approach requires significant test coverage and maturity of the engineering culture. I assumed this is out of this test project.

### Infrastructure Automation

#### Terraform Configuration
- **State Management**: GCS backend for state storage
- **Resource Provisioning**: Cloud Run, IAM, and storage resources
- **Environment Management**: Variable-based environment configuration
- **Security Hardening**: IAM policies and network security

#### Monitoring & Observability
- **Health Endpoints**: `/healthz/liveness` and `/healthz/readiness`
- **Logging**: Structured logging for application events
- **Metrics**: Cloud Run built-in metrics and monitoring
- **Alerting**: Cloud Monitoring integration (configurable)

## 🧪 Testing

### Test Structure
- **Integration Tests**: API endpoint testing with database

### Running Tests
```bash
# Run all tests
npm test

```