# BillPay - Guía Rápida para Reiniciar Contexto

## 🚀 INICIO RÁPIDO DE CONTEXTO

### **Cuando reinicies el chat, carga estos 3 archivos en este orden:**

#### 1. **CONTEXTO PRINCIPAL** (OBLIGATORIO)
```
/home/giovanemere/periferia/billpay/docs/CONTEXT_PROMPT.md
```
**Contiene**: Objetivo, arquitectura, estructura completa, herramientas MCP, próximos pasos

#### 2. **RESUMEN EJECUTIVO** (OBLIGATORIO)
```
/home/giovanemere/periferia/billpay/docs/PROJECT_SUMMARY.md
```
**Contiene**: Estado 100% definido, documentación completa, análisis completitud

#### 3. **README PRINCIPAL** (RECOMENDADO)
```
/home/giovanemere/periferia/billpay/README.md
```
**Contiene**: Overview, estructura, herramientas MCP, comandos útiles

## 📋 COMANDO RÁPIDO DE ESTADO

**Después de cargar contexto, ejecuta:**
```bash
./scripts/project-status.sh
```

## 🎯 FRASE DE CONTEXTO RÁPIDO

**Copia y pega esto al reiniciar:**

> "Proyecto BillPay - Plataforma de pagos enterprise con microservicios en AWS. Fase actual: 2A (Infraestructura Base). Documentación 100% completa. Herramientas MCP operativas. Listo para implementación. Próximo: setup_complete_infrastructure."

## 📊 ARCHIVOS ADICIONALES (SEGÚN NECESIDAD)

### **Para planificación detallada:**
```
/home/giovanemere/periferia/billpay/docs/deployment-plan.md
```

### **Para prerequisitos:**
```
/home/giovanemere/periferia/billpay/docs/PREREQUISITES.md
```

### **Para estructura detallada:**
```
/home/giovanemere/periferia/billpay/docs/PROJECT_STRUCTURE.md
```

## 🔧 COMANDOS ÚTILES POST-CONTEXTO

```bash
# Ver estado actual
./scripts/project-status.sh

# Verificar prerequisitos
./scripts/check-prerequisites.sh

# Iniciar despliegue (si prerequisitos OK)
setup_complete_infrastructure --projectName=billpay --environment=dev
```

## 📍 UBICACIÓN DEL PROYECTO
```
/home/giovanemere/periferia/billpay/
```

---

**Última actualización**: 2025-09-23  
**Uso**: Cargar al reiniciar chat para contexto completo
