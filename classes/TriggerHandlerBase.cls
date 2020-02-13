/*------------------------------------------------------------
Author:        Ian Huang
Company:       Salesforce
Description:   Trigger template trigger handler base
------------------------------------------------------------*/
public abstract class TriggerHandlerBase implements Triggers.IHandler {
    
    private static final Integer DEFAULT_EXECUTION_COUNT = 999;
    public Integer maximumExecutionCount;
    
    protected TriggerDataManagerBase dataManager      {get; set;}
    protected TriggerParameters      triggerParameter {get; set;}

    public TriggerBaseHandler() {
        this.maximumExecutionCount = DEFAULT_EXECUTION_COUNT;
    }
    
    public TriggerBaseHandler setMaximumExecutionCount(Integer maxExecutionCount) {
        this.maximumExecutionCount = maxExecutionCount;
        return this;
    }
    
    public abstract void handle();
    
    public virtual void bindDataManager(TriggerDataManagerBase dataManager) {
        this.dataManager = dataManager;
    }

    public virtual void bindTriggerParameter(TriggerParameters triggerParameter) {
        this.triggerParameter = triggerParameter;
    }

}