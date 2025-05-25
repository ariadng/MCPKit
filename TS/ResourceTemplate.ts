/**
 * A template description for resources available on the server.
 */
import { Annotations } from './Annotations';

export interface ResourceTemplate {
  /**
   * A template for the URI of the resource. The URI can use any protocol; it is up to the server how to interpret it.
   * The template may contain placeholders in the form {name} which can be replaced with values to generate a valid URI.
   * 
   * @format uri-template
   */
  uriTemplate: string;
  
  /**
   * A human-readable name for the resource template.
   */
  name: string;
  
  /**
   * An optional human-readable description of the resource template.
   */
  description?: string;
  
  /**
   * The MIME type of resources generated from this template, if known.
   */
  mimeType?: string;
  
  /**
   * Optional annotations for the client.
   */
  annotations?: Annotations;
}
