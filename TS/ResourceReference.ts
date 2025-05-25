/**
 * A reference to a resource or resource template definition.
 */
export interface ResourceReference {
  type: "ref/resource";
  
  /**
   * The URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.
   * 
   * @format uri
   */
  uri: string;
}
