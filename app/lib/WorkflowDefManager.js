class WorkflowDefManager {

    validateWorkflowDef(workflowDef) {
        let errors = [];
        if (!workflowDef.steps.start) {
            errors.push("Worflow definition doesn't have a 'start' step");
        }
        for (let [name, step] of Object.entries(workflowDef.steps)) {
            if (!workflowDef.actionHandlers[name]) {
                errors.push(`No action handler for step: '${name}'`);
            }
            for (let [event, stepName] of Object.entries(step)) {
                if (!workflowDef.steps[stepName]) {
                    errors.push(`Event '${event}' triggers invalid step '${stepName}'`);
                }
            }
        }
        return errors
    }

}

module.exports = new WorkflowDefManager()