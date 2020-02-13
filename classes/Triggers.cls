/*------------------------------------------------------------
Author:        Abhinav Gupta
Company:       Concret.io
Description:   Trigger template - Trigger interface template
               http://www.tgerm.com/2012/01/salesforce-apex-trigger-template.html
History:       2012-01-02   Abhinav Gupta   Created.
------------------------------------------------------------*/

public class Triggers {
    /**
        Enum representing each of before/after CRUD events on Sobjects
    */
    public enum Evt {
        afterdelete,
        afterinsert,
        afterundelete,
        afterupdate,
        beforedelete,
        beforeinsert,
        beforeupdate
    }

    /**
        Simplistic handler to implement on any of the event. It doesn't require or enforce any pattern except the
        method name - "handle()", a developer is free to use any Trigger context variable or reuse any other
        apex class here.
    */
    public interface IHandler {
        void handle();
        void bindDataManager(TriggerDataManagerBase dm);
        void bindTriggerParameter(TriggerParameters tp);
    }

    // Internal mapping of handlers
    private Map<String, List<IHandler>> eventHandlerMapping = new Map<String, List<IHandler>>();
    private TriggerDataManagerBase      dataManager;
    private TriggerParameters           triggerParameter;
    private static Map<String, Integer> triggerExecutionMap = new Map<String, Integer>();  
    
    public static Boolean interactiveMute = false; // Used to temporarily mute triggers during test data loading
    
    public Triggers() {
        List<SObject> triggerOldList = new List<SObject>();
        Map<Id, SObject> triggerOldMap = new Map<Id, SObject>();
        List<SObject> triggerNewList = new List<SObject>();
        Map<Id, SObject> triggerNewMap = new Map<Id, SObject>();

        if (Trigger.isUpdate || Trigger.isDelete) {
            for (SObject oOld : Trigger.old) {
                triggerOldList.add(oOld);
                triggerOldMap.put(oOld.Id, oOld);
            }
        }

        if (!Trigger.isDelete) {
            for (SObject oNew : Trigger.new) {
                triggerNewList.add(oNew);
                triggerNewMap.put(oNew.Id, oNew);
            }
        }

        triggerParameter = new TriggerParameters(triggerOldList, triggerNewList, triggerOldMap, triggerNewMap,
                Trigger.isBefore, Trigger.isAfter, Trigger.isDelete,
                Trigger.isInsert, Trigger.isUpdate, Trigger.isUnDelete, Trigger.isExecuting);
    }


    public Triggers bindDataManager(TriggerDataManagerBase dm) {
        this.dataManager = dm;
        this.dataManager.bindTriggerParameter(this.TriggerParameter);

        return this;
    }
    
    public static void resetTriggerExecutionCount() {
        triggerExecutionMap.clear();
    }

    /**
        Core API to bind handlers with events
    */
    public Triggers bind(Evt event, IHandler eh) {

        eh.bindDataManager(this.dataManager);
        eh.bindTriggerParameter(this.triggerParameter);

        List<IHandler> handlers = eventHandlerMapping.get(event.name());
        if (handlers == null) {
            handlers = new List<IHandler>();
            eventHandlerMapping.put(event.name(), handlers);
        }

        // Add a concrete handler to our invocation list
        handlers.add(eh);
        return this;
    }

    /**
        Invokes correct handlers as per the context of trigger and available registered handlers
    */
    public void execute() {

        if (isMuted() || interactiveMute) {
            return;
        }
         
        Evt ev = null;
        if (Trigger.isInsert && Trigger.isBefore) {
            ev = Evt.beforeinsert;
        } else if (Trigger.isInsert && Trigger.isAfter) {
            ev = Evt.afterinsert;
        } else if (Trigger.isUpdate && Trigger.isBefore) {
            ev = Evt.beforeupdate;
        } else if (Trigger.isUpdate && Trigger.isAfter) {
            ev = Evt.afterupdate;
        } else if (Trigger.isDelete && Trigger.isBefore) {
            ev = Evt.beforedelete;
        } else if (Trigger.isDelete && Trigger.isAfter) {
            ev = Evt.afterdelete;
        } else if (Trigger.isundelete) {
            ev = Evt.afterundelete;
        }
        
        String triggerKey = triggerParameter.triggerObject.toUpperCase() + String.valueOf(ev).toUpperCase();

        List<IHandler> handlers = eventHandlerMapping.get(ev.name());
        if (handlers != null && !handlers.isEmpty()) {            
            if (!triggerExecutionMap.containsKey(triggerKey))
                triggerExecutionMap.put(triggerKey, 0);
            
            Integer executionCount = triggerExecutionMap.get(triggerKey);
            Boolean isDataLoaded = false;
            for (Integer i = 0; i < handlers.size(); i++) {
                //Executes handler if execution has not reached the limit
                if (executionCount < ((TriggerBaseHandler)handlers[i]).maximumExecutionCount) {
                    //If there is a dataManager and data is not loaded yet, then load the data
                    if (dataManager != null && !isDataLoaded) {
                        dataManager.loadData(); //2018-02-01 HH: Moved loadData to here where we know there is at lease one handler would be called
                        isDataLoaded = true;
                    }

                    handlers[i].handle();
                }
            }
            triggerExecutionMap.put(triggerKey, executionCount + 1);
        }

        if (dataManager != null) {
            dataManager.commitCoreChanges();
            dataManager.commitChanges();
            dataManager.handleErrors();
        }
    }

    public Boolean isMuted() {
        return Bypass_Setting__c.getInstance().Bypass_Trigger__c;
    }
    
}