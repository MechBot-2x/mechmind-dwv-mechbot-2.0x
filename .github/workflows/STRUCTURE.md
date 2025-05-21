### **Estructura Detallada del Directorio**  
```plaintext
.github/  
└── workflows/  
    ├── ci.yml                   # Integración continua (tests, builds, análisis)  
    ├── cd-prod.yml              # Despliegue en producción (AWS EKS/GCP)  
    ├── cd-staging.yml           # Despliegue en entorno de staging  
    ├── security-scans.yml       # Escaneos de seguridad (SAST, SCA, secretos)  
    ├── dependency-updates.yml   # Actualización automática de dependencias  
    ├── release.yml              # Generación de releases semánticos  
    ├── infra-as-code-checks.yml # Validación de Terraform/Kubernetes  
    └── notify-status.yml        # Notificaciones a Slack/Teams
```
