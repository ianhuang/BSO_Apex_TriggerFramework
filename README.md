# Business Scenario Oriented Apex Trigger Framework

## Summary
* Simplicity
* Readability 
* Separation of Concerns
* Multi-Dev Stream Friendly
* Order of Execution
* Muting

### Simplicity, Readability & Maintainability
* 2 level simple structure for easy access and readability
* Descriptive business scenario based trigger handler name for easy understanding of business purpose
* Easy maintenance of single purpose handler class

### Separation of Concerns
* Trigger - High level trigger execution flow
* Trigger handler class - Detailed business logic code

### Multi Development Stream Friendly
* Single purpose handler class means you will never override code of one another

### Order of Execution
* First binding first execution

### Data loading & DML Consolidation
* TriggerDataManager for common data loading
* TriggerDataManager for DML

### Trigger bypass & Muting
* Configurable trigger muting
* Profile & user level control


### Framework Classes
* Triggers
* TriggerHandlerBase
* TriggerDataManagerBase
* TriggerParameters

## Sample Code 

```
trigger CaseTrigger on Case(before insert,after insert, before update,after update, before delete, after delete) {

  new Triggers() 
    .bind(Triggers.Evt.BeforeUpdate, new updateCaseMilestoneHandler()) 
    .bind(Triggers.Evt.AfterUpdate, new referralEmailHandler()) 
    .bind(Triggers.Evt.AfterInsert, new socialChannelInboundHandler()) 
    .execute();

}
```
```
public class updateCaseMilestoneHandler extends TriggerHandlerBase {

  public override void Handle() { 
    try { set caseIdSet = new set();
      for (Case c :(List)TriggerParameter.newList) { 
        Case oldRecord = (Case)TriggerParameter.oldMap.get(c.Id); 
        caseIdSet.add(c.Id); 
      } 
    } catch(Exception ex) {
    } 
  }
  
}
```
