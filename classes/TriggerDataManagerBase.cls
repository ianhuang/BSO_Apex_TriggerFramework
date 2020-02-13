/*------------------------------------------------------------
Author:        Ian Huang
Company:       Salesforce
Description:   Trigger template - Base Trigger Data Manager class
------------------------------------------------------------*/
public abstract class TriggerDataManagerBase {

    public Set<sObject> objectsToInsert = new Set<sObject>();
    public Set<sObject> objectsToUpdate = new Set<sObject>();
    public Set<sObject> objectsToDelete = new Set<sObject>();

    public List<Database.SaveResult> insertResult = new List<Database.SaveResult>();
    public List<Database.SaveResult> updateResult = new List<Database.SaveResult>();
    public List<Database.DeleteResult> deleteResult = new List<Database.DeleteResult>();

    protected TriggerParameters triggerParameter;

    public void loadData() {
        if (Trigger.isBefore) {
            loadBeforeEventsData();
        } else if (Trigger.isAfter) {
            loadAfterEventsData();
        }
    }

    protected virtual void loadBeforeEventsData() {
    }

    protected virtual void loadAfterEventsData() {
    }

    public void commitCoreChanges() {
        if (!objectsToInsert.isEmpty()) insertResult = Database.insert(new List<sObject>(objectsToInsert));
        if (!objectsToUpdate.isEmpty()) updateResult = Database.update(new List<sObject>(objectsToUpdate));
        if (!objectsToDelete.isEmpty()) deleteResult = Database.delete(new List<sObject>(objectsToDelete));        
    }

    public virtual void commitChanges() {

    }

    public virtual void handleErrors() {
        for (Integer i = 0; i < insertResult.size(); i ++) {
            Database.SaveResult result = insertResult[i];
            if (!result.isSuccess()) {
                for (Database.Error e : result.getErrors()) {
                    throw new TriggerDataManagerException(e.getMessage());
                }
            }
        }  

        for (Integer i = 0; i < updateResult.size(); i ++) {
            Database.SaveResult result = updateResult[i];
            if (!result.isSuccess()) {
                for (Database.Error e : result.getErrors()) {
                    throw new TriggerDataManagerException(e.getMessage());
                }
            }
        } 

        for (Integer i = 0; i < deleteResult.size(); i ++) {
            Database.DeleteResult result = deleteResult[i];
            if (!result.isSuccess()) {
                for (Database.Error e : result.getErrors()) {
                    throw new TriggerDataManagerException(e.getMessage());
                }
            }
        }                           
    }

    public void bindTriggerParameter(TriggerParameters tp) {
        this.triggerParameter = tp;
    }

    public class TriggerDataManagerException extends Exception {}
}