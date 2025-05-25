/**
 * The contents of a specific resource or sub-resource.
 */
export interface ResourceContents {
  /**
   * The URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.
   * 
   * @format uri
   */
  uri: string;
  
  /**
   * The MIME type of the resource, if known.
   */
  mimeType?: string;
}
