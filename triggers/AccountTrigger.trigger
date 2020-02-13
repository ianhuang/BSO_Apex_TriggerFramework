trigger AccountTrigger on Account (after update) {

    //skip trigger execution if bypass trigger setting is set to true 
    if(Bypass_Setting__c.getInstance().Bypass_Trigger__c) {
        return;
    }

    new Triggers()
        .bind(Triggers.Evt.beforeInsert, new AccountUpdateSomethingHandler())
        .bind(Triggers.Evt.beforeUpdate, new AccountUpdateSomethingHandler())
        .bind(Triggers.Evt.afterUpdate,  new AccountUpdateContactAddressHandler())
        .execute();
        
        
}