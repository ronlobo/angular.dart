part of angular.core;

class NgAnnotation {
  /**
   * CSS selector which will trigger this component/directive.
   * CSS Selectors are limited to a single element and can contain:
   *
   * * `element-name` limit to a given element name.
   * * `.class` limit to an element with a given class.
   * * `[attribute]` limit to an element with a given attribute name.
   * * `[attribute=value]` limit to an element with a given attribute and value.
   *
   *
   * Example: `input[type=checkbox][ng-model]`
   */
  final String selector;

  /**
   * Specifies the compiler action to be taken on the child nodes of the
   * element which this currently being compiled.  The values are:
   *
   * * [COMPILE_CHILDREN] (*default*)
   * * [TRANSCLUDE_CHILDREN]
   * * [IGNORE_CHILDREN]
   */
  final String children;

  /**
   * Compile the child nodes of the element.  This is the default.
   */
  static const String COMPILE_CHILDREN = 'compile';
  /**
   * Compile the child nodes for transclusion and makes available
   * [BoundBlockFactory], [BlockFactory] and [BlockHole] for injection.
   */
  static const String TRANSCLUDE_CHILDREN = 'transclude';
  /**
   * Do not compile/visit the child nodes.  Angular markup on descendant nodes
   * will not be processed.
   */
  static const String IGNORE_CHILDREN = 'ignore';

  /**
   * A directive/component controller class can be injected into other
   * directives/components. This attribute controls whether the
   * controller is available to others.
   *
   * * `local` [NgDirective.LOCAL_VISIBILITY] - the controller can be injected
   *   into other directives / components on the same DOM element.
   * * `children` [NgDirective.CHILDREN_VISIBILITY] - the controller can be
   *   injected into other directives / components on the same or child DOM
   *   elements.
   * * `direct_children` [NgDirective.DIRECT_CHILDREN_VISIBILITY] - the
   *   controller can be injected into other directives / components on the
   *   direct children of the current DOM element.
   */
  final String visibility;
  final List<Type> publishTypes;

  /**
   * Use map to define the mapping of  DOM attributes to fields.
   * The map's key is the DOM attribute name (DOM attribute is in dash-case).
   * The Map's value consists of a mode prefix followed by an expression.
   * The destination expression will be evaluated against the instance of the
   * directive / component class.
   *
   * * `@` - Map the DOM attribute string. The attribute string will be taken
   *   literally or interpolated if it contains binding {{}} systax and assigned
   *   to the expression. (cost: 0 watches)
   *
   * * `=>` - Treat the DOM attribute value as an expression. Set up a watch,
   *   which will read the expression in the attribute and assign the value
   *   to destination expression. (cost: 1 watch)
   *
   * * `<=>` - Treat the DOM attribute value as an expression. Set up a watch
   *   on both outside as well as component scope to keep the src and
   *   destination in sync. (cost: 2 watches)
   *
   * * `=>!` - Treat the DOM attribute value as an expression. Set up a one time
   *   watch on expression. Once the expression turns truthy it will no longer
   *   update. (cost: 1 watches until not null, then 0 watches)
   *
   * * `&` - Treat the DOM attribute value as an expression. Assign a closure
   *   function into the field. This allows the component to control
   *   the invocation of the closure. This is useful for passing
   *   expressions into controllers which act like callbacks. (cost: 0 watches)
   *
   * Example:
   *
   *     <my-component title="Hello {{username}}"
   *                   selection="selectedItem"
   *                   on-selection-change="doSomething()">
   *
   *     @NgComponent(
   *       selector: 'my-component'
   *       map: const {
   *         'title': '@title',
   *         'selection': '<=>currentItem',
   *         'on-selection-change': '&onChange'
   *       }
   *     )
   *     class MyComponent {
   *       String title;
   *       var currentItem;
   *       ParsedFn onChange;
   *     }
   *
   *  The above example shows how all three mapping modes are used.
   *
   *  * `@title` maps the title DOM attribute to the controller `title`
   *    field. Notice that this maps the content of the attribute, which
   *    means that it can be used with `{{}}` interpolation.
   *
   *  * `<=>currentItem` maps the expression (in this case the `selectedItem`
   *    in the current scope into the `currentItem` in the controller. Notice
   *    that mapping is bi-directional. A change either in field or on
   *    parent scope will result in change to the other.
   *
   *  * `&onChange` maps the expression into tho controllers `onChange`
   *    field. The result of mapping is a callable function which can be
   *    invoked at any time by the controller. The invocation of the
   *    callable function will result in the expression `doSomething()` to
   *    be executed in the parent context.
   */
  final Map<String, String> map;

  /**
   * Use the list to specify expression containing attributes which are not
   * included under [map] with '=' or '@' specification.
   */
  final List<String> exportExpressionAttrs;

  /**
   * Use the list to specify a expressions which are evaluated dynamically
   * (ex. via [Scope.$eval]) and are otherwise not statically discoverable.
   */
  final List<String> exportExpressions;

  /**
   * An expression under which the controller instance will be published into.
   * This allows the expressions in the template to be referring to controller
   * instance and its properties.
   */
  final String publishAs;

  const NgAnnotation({
    this.selector,
    this.children: NgAnnotation.COMPILE_CHILDREN,
    this.visibility: NgDirective.LOCAL_VISIBILITY,
    this.publishAs,
    this.publishTypes: const [],
    this.map: const {},
    this.exportExpressions: const [],
    this.exportExpressionAttrs: const []
  });

  toString() => selector;
  get hashCode => selector.hashCode;
  operator==(other) =>
      other is NgAnnotation && this.selector == other.selector;

}


/**
 * Meta-data marker placed on a class which should act as a controller for the
 * component. Angular components are a light-weight version of web-components.
 * Angular components use shadow-DOM for rendering their templates.
 *
 * Angular components are instantiated using dependency injection, and can
 * ask for any injectable object in their constructor. Components
 * can also ask for other components or directives declared on the DOM element.
 *
 * Components can implement [NgAttachAware], [NgDetachAware], [NgShadowRoot] and
 * declare these optional methods:
 *
 * * `attach()` - Called on first [Scope.$digest()].
 * * `detach()` - Called on when owning scope is destroyed.
 * * `onShadowRoot(ShadowRoot shadowRoot)` - Called when [ShadowRoot] is loaded.
 */
class NgComponent extends NgAnnotation {
  /**
   * Inlined HTML template for the component.
   */
  final String template;

  /**
   * A URL to HTML template. This will be loaded asynchronously and
   * cached for future component instances.
   */
  final String templateUrl;

  /**
   * A CSS URL to load into the shadow DOM.
   */
  final String cssUrl;

  /**
   * Set the shadow root applyAuthorStyles property. See shadow-DOM
   * documentation for further details.
   */
  final bool applyAuthorStyles;

  /**
   * Set the shadow root resetStyleInheritance property. See shadow-DOM
   * documentation for further details.
   */
  final bool resetStyleInheritance;

  const NgComponent({
    this.template,
    this.templateUrl,
    this.cssUrl,
    this.applyAuthorStyles,
    this.resetStyleInheritance,
    publishAs,
    map,
    selector,
    visibility,
    publishTypes : const <Type>[],
    exportExpressions,
    exportExpressionAttrs
  }) : super(selector: selector,
             children: NgAnnotation.COMPILE_CHILDREN,
             visibility: visibility,
             publishTypes: publishTypes,
             publishAs: publishAs,
             map: map,
             exportExpressions: exportExpressions,
             exportExpressionAttrs: exportExpressionAttrs);
}

RegExp _ATTR_NAME = new RegExp(r'\[([^\]]+)\]$');

/**
 * Meta-data marker placed on a class which should act as a directive.
 *
 * Angular directives are instantiated using dependency injection, and can
 * ask for any injectable object in their constructor. Directives
 * can also ask for other components or directives declared on the DOM element.
 *
 * Directives can implement [NgAttachAware], [NgDetachAware] and
 * declare these optional methods:
 *
 * * `attach()` - Called on first [Scope.$digest()].
 * * `detach()` - Called on when owning scope is destroyed.
 */
class NgDirective extends NgAnnotation {
  static const String LOCAL_VISIBILITY = 'local';
  static const String CHILDREN_VISIBILITY = 'children';
  static const String DIRECT_CHILDREN_VISIBILITY = 'direct_children';

  const NgDirective({
                    children: NgAnnotation.COMPILE_CHILDREN,
                    publishAs,
                    map,
                    selector,
                    visibility,
                    publishTypes : const <Type>[],
                    exportExpressions,
                    exportExpressionAttrs
                    }) : super(selector: selector, children: children, visibility: visibility,
  publishTypes: publishTypes, publishAs: publishAs, map: map,
  exportExpressions: exportExpressions,
  exportExpressionAttrs: exportExpressionAttrs);
}

/**
 * Meta-data marker placed on a class which should act as a controller for your application.
 *
 * Controllers are essentially [NgDirectives] with few key differences:
 *
 * * Controllers create a new scope at the element.
 * * Controllers should not do any DOM manipulation.
 * * Controllers are meant for application-logic
 *   (rather then DOM monipulation logic which directives are meant for.)
 *
 * Controllers can implement [NgAttachAware], [NgDetachAware] and
 * declare these optional methods:
 *
 * * `attach()` - Called on first [Scope.$digest()].
 * * `detach()` - Called on when owning scope is destroyed.
 */
class NgController extends NgDirective {
  static const String LOCAL_VISIBILITY = 'local';
  static const String CHILDREN_VISIBILITY = 'children';
  static const String DIRECT_CHILDREN_VISIBILITY = 'direct_children';

  const NgController({
                    children: NgAnnotation.COMPILE_CHILDREN,
                    publishAs,
                    map,
                    selector,
                    visibility,
                    publishTypes : const <Type>[],
                    exportExpressions,
                    exportExpressionAttrs
                    }) : super(selector: selector, children: children, visibility: visibility,
  publishTypes: publishTypes, publishAs: publishAs, map: map,
  exportExpressions: exportExpressions,
  exportExpressionAttrs: exportExpressionAttrs);
}

/**
 * Implementing directives or components [attach] method will be called when
 * the next scope digest occurs after component instantiation. It is guaranteed
 * that when [attach] is invoked, that all attribute mappings have already
 * been processed.
 */
abstract class NgAttachAware {
  void attach();
}

/**
 * Implementing directives or components [detach] method will be called when
 * the associated scope is destroyed.
 */
abstract class NgDetachAware {
  void detach();
}

class DirectiveMap extends AnnotationMap<NgAnnotation> {
  DirectiveMap(Injector injector, MetadataExtractor metadataExtractor)
      : super(injector, metadataExtractor);
}
