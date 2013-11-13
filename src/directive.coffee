
# ----------------------------------------
# builder.directive
# ----------------------------------------
a = angular.module 'builder.directive', ['builder.provider', 'builder.controller', 'builder.drag']


# ----------------------------------------
# fb-builder, fb-droppable
# ----------------------------------------
fbBuilder = ($injector) ->
    restrict: 'A'
    template:
        """
        <div class='form-horizontal'>
            <div class='fb-form-object' ng-repeat="object in formObjects"
                fb-form-object="object"></div>
        </div>
        """
    controller: 'fbBuilderController'
    link: (scope, element, attrs) ->
        # ----------------------------------------
        # providers
        # ----------------------------------------
        $builder = $injector.get '$builder'
        $drag = $injector.get '$drag'

        # ----------------------------------------
        # valuables
        # ----------------------------------------
        scope.formName = attrs.fbBuilder
        $builder.forms[scope.formName] ?= []
        scope.formObjects = $builder.forms[scope.formName]

        $(element).addClass 'fb-builder'
        $drag.droppable $(element),
            mode: 'custom'
            move: (e, draggable) ->
                $formObjects = $(element).find '.fb-form-object:not(.empty,.dragging)'
                if $formObjects.length is 0
                    # there are no components in the builder.
                    if $(element).find('.fb-form-object.empty') is 0
                        $(element).append $("<div class='fb-form-object empty'></div>")
                    return

                # the positions could added .empty div.
                positions = []
                # first
                positions.push -1000
                positions.push $($formObjects[0]).offset().top + $($formObjects[0]).height() / 2
                for index in [0..$formObjects.length - 1]
                    continue if index is 0
                    $formObject = $($formObjects[index])
                    offset = $formObject.offset()
                    height = $formObject.height()
                    positions.push offset.top + height / 2
                positions.push positions[positions.length - 1] + 1000   # last

                # search where should I insert the .empty
                for index in [0..positions.length - 1]
                    continue if index is 0
                    if e.pageY > positions[index - 1] and e.pageY <= positions[index]
                        # this one
                        $(element).find('.empty').remove()
                        $empty = $ "<div class='fb-form-object empty'></div>"
                        if index - 1 < $formObjects.length
                            $empty.insertBefore $($formObjects[index - 1])
                        else
                            $empty.insertAfter $($formObjects[index - 2])
                        break
                return
            out: (e, draggable) ->
                $(element).find('.empty').remove()
            up: (e, draggable) ->
                $(element).find('.empty').remove()
fbBuilder.$inject = ['$injector']
a.directive 'fbBuilder', fbBuilder

# ----------------------------------------
# fb-form-object
# ----------------------------------------
fbFormObject = ($injector) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
        # providers
        $builder = $injector.get '$builder'
        $drag = $injector.get '$drag'
        $parse = $injector.get '$parse'
        $compile = $injector.get '$compile'

        # valuables
        component = $builder.components[scope.object.component]
        scope.$watch 'object', ->
            for key, value of scope.object when key isnt '$$hashKey'
                # ng-repeat="object in formObjects"
                # copy scope.object.{} to scope.{}
                scope[key] = value
        , true

        # draggable
        $drag.draggable $(element)

        # compile formObject
        $template = $(component.template)
        view = $compile($template) scope
        $(element).append view

        # ----------------------------------------
        # bootstrap popover
        # ----------------------------------------
        popoverId = "fo-#{Math.random().toString().substr(2)}"
        popover =
            view: null
            html:
                """
                <form class='#{popoverId}'>
                    <div class="form-group">
                        <label class='control-label col-md-10'>Label</label>
                        <div class="col-md-10">
                            <input type='text' ng-model="object.label" class='form-control '/>
                        </div>
                    </div>
                </form>
                """
        popover.view = $compile(popover.html) scope
        $(element).addClass popoverId
        $(element).popover
            html: yes
            title: component.label
            content: popover.view
        $(element).on 'hide.bs.popover', ->
            # do not remove the DOM
            $("form.#{popoverId}").closest('.popover').removeClass 'in'
            false
        $(element).on 'show.bs.popover', ->
            $popover = $("form.#{popoverId}").closest '.popover'
            if $popover.length > 0
                $popover.addClass 'in'
                $(element).triggerHandler 'shown.bs.popover'
                false
        $(element).on 'shown.bs.popover', ->
            # select the first input
            $(".popover .#{popoverId} input:first").select()
        $(element).on 'click', ->
            # hide other popovers
            $("div.fb-form-object:not(.#{popoverId})").popover 'hide'
fbFormObject.$inject = ['$injector']
a.directive 'fbFormObject', fbFormObject


# ----------------------------------------
# fb-components
# ----------------------------------------
fbComponents = ($injector) ->
    restrict: 'A'
    template:
        """
        <ul ng-if="groups.length > 1" class="nav nav-tabs nav-justified">
            <li ng-repeat="group in groups" ng-class="{active:status.activeGroup==group}">
                <a href='#' ng-click="action.selectGroup($event, group)">{{group}}</a>
            </li>
        </ul>
        <div class='form-horizontal'>
            <div class='fb-component'
                ng-repeat="component in components|filter:{group:status.activeGroup}"
                fb-component="component"></div>
        </div>
        """
    controller: 'fbComponentsController'

fbComponents.$inject = ['$injector']
a.directive 'fbComponents', fbComponents

# ----------------------------------------
# fb-component
# ----------------------------------------
fbComponent = ($injector) ->
    restrict: 'A'
    link: (scope, element, attrs) ->
        # providers
        $builder = $injector.get '$builder'
        $drag = $injector.get '$drag'
        $parse = $injector.get '$parse'
        $compile = $injector.get '$compile'

        # valuables
        cs = scope.$new()   # component scope
        component = $parse(attrs.fbComponent) scope
        $.extend cs, component

        $drag.draggable $(element),
            mode: 'mirror'
            defer: no

        $template = $(component.template)
        view = $compile($template) cs
        $(element).append view
fbComponent.$inject = ['$injector']
a.directive 'fbComponent', fbComponent


# ----------------------------------------
# fb-form
# ----------------------------------------
fbForm = ($injector) ->
    restrict: 'A'
    require: 'ngModel'  # form data (user input value)
    link: (scope, element, attrs) ->
        name = attrs.fbForm
        console.log 'form'

fbForm.$inject = ['$injector']
a.directive 'fbForm', fbForm

