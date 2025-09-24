# Plan de Limpieza Backstage - BillPay

## 🎯 OBJETIVO
Limpiar y consolidar templates duplicados, catálogo, documentación y APIs de Backstage para el proyecto BillPay.

## 🧹 PLAN DE LIMPIEZA (5 PASOS)

### **PASO 1: Auditoría de Duplicados**
- [ ] Identificar documentación redundante en `/repositories/templates_backstage/docs/`
- [ ] Detectar configuraciones duplicadas (`mkdocs.yml`, configs)
- [ ] Mapear referencias cruzadas entre docs
- [ ] Listar archivos obsoletos

### **PASO 2: Limpieza de Catálogo**
- [ ] Revisar `catalog-info.yaml` en templates_backstage
- [ ] Eliminar entradas duplicadas o obsoletas
- [ ] Actualizar referencias a servicios
- [ ] Validar estructura del catálogo

### **PASO 4: Reorganización de Documentación**
- [ ] Eliminar `/repositories/templates_backstage/docs/` (duplicada)
- [ ] Consolidar toda la documentación en `/docs/` principal
- [ ] Actualizar referencias en templates
- [ ] Eliminar `mkdocs.yml` duplicado

### **PASO 5: Limpieza de Configuraciones**
- [ ] Revisar `backstage-config-example.yaml`
- [ ] Eliminar configuraciones obsoletas
- [ ] Consolidar configs necesarias
- [ ] Actualizar referencias

### **PASO 6: Validación Final**
- [ ] Probar template `billpay-complete-stack`
- [ ] Verificar catálogo funciona
- [ ] Validar documentación accesible
- [ ] Test de integración completo

## 🚀 EJECUCIÓN PASO A PASO

¿Por cuál paso quieres empezar?

1. **PASO 1** - Auditoría de duplicados
2. **PASO 2** - Limpieza de catálogo  
3. **PASO 4** - Reorganización de docs
4. **PASO 5** - Limpieza de configs
5. **PASO 6** - Validación final

## 📊 CRITERIOS DE ÉXITO
- ✅ Sin documentación duplicada
- ✅ Catálogo limpio y funcional
- ✅ Configuraciones consolidadas
- ✅ Template operativo
- ✅ Referencias actualizadas

---
**Estado**: Listo para ejecutar  
**Tiempo estimado**: 1-2 horas
