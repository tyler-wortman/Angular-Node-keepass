
a = angular.module 'builder.components', ['builder']

config = ($builderProvider) ->
    # ----------------------------------------
    # textInput
    # ----------------------------------------
    $builderProvider.registerComponent 'textInput',
        label: 'Text Input'
        description: 'description'
        placeholder: 'placeholder'
        required: false
        template:
            """
            <div class="form-group">
                <label for="{{name}}" ng-bind="label" class="col-md-2 control-label"></label>
                <div class="col-md-10">
                    <input type="text" validator="{{validation}}" id="{{name}}" class="form-control" placeholder="{{placeholder}}"/>
                </div>
            </div>
            """

config.$inject = ['$builderProvider']
a.config config
