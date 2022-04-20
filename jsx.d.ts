/// <reference path="./intrinsic-elements.d.ts" />

declare module "resty.jsx" {
    interface ServerSideHtml {
        html: string
    }
    
    type ChildElement = FlatChildElement | ChildElement[];
    type FlatChildElement = ServerSideHtml | string | number;
    
    export function createElement(tag: string | Function, props: { [key: string]: string | boolean }, ...children: ChildElement[]): ServerSideHtml;
}
