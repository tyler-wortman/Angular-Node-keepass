
a = angular.module 'builder.provider', []

a.provider '$builder', ->
    # ----------------------------------------
    # providers
    # ----------------------------------------
    $injector = null


    # ----------------------------------------
    # properties
    # ----------------------------------------
    # all components
    @components = {}
    # builders.
    #   builder mode: `fb-builder` you could drag and drop to build this builder.
    #   form mode: `fb-form` this is the form for user to input value.
    @builders = {}


    # ----------------------------------------
    # private functions
    # ----------------------------------------
    @setupProviders = (injector) ->
        $injector = injector

    @convertComponent = (name, component) ->
        result =
            name: name
            label: component.label ? ''
            description: component.description ? ''
            placeholder: component.placeholder ? ''
            required: component.required ? false
            validation: component.validation ? /.*/
            template: component.template ?
                """
                <div class="form-group">
                    <label for="{{name}}" class="col-md-2 control-label" ng-bind="label"></label>
                    <div class="col-md-10">
                        <input type="text" validator="{{validation}}" ng-model="input" class="form-control" id="{{name}}" placeholder="{{placeholder}}"/>
                    </div>
                </div>
                """

        result


    # ----------------------------------------
    # public functions
    # ----------------------------------------
    @registerComponent = (name, component={}) =>
        ###
        Register the component for form-builder.
        @param name: The component name.
        @param component: The component object.

        ###
        @components[name] = @convertComponent name, component

    @loadBuilder = (name, object=[]) ->
        ###
        Load the form information into the builder which name is `name`.
        @param name: The builder name.
        @param object: The form information.
        ###


    # ----------------------------------------
    # $get
    # ----------------------------------------
    @get = ($injector) ->
        @setupProviders $injector
        @builders[''] = []

        components: @components
        builders: @builder
        registerComponent: @registerComponent
        loadBuilder: @loadBuilder
    @get.$inject = ['$injector']
    @$get = @get
