## JSX in Openresty

Thanks to [TypescriptToLua](https://typescripttolua.github.io/) project, we can write web applications for Openresty
in Typescript, which is pretty cool!

Now, if we want to return HTML from the server, even though there are some really good HTML templating libraries available,
but coming from Typescript background, I find it really convenient to generate HTML with JSX, because unlike HTML templates,
it is 100% covered by intellisense, which drastically reduces amount of errors you make.

This library enables using JSX in TypescriptToLua projects.

### How to use

Install from NPM:

```bash
npm i resty.jsx
```

Add the following code to **tsconfig.json**:

```json
{
    "compilerOptions": {
        ...
        "jsx": "react",
        "jsxFactory": "createElement",
        ...
    }
}
```

Add the following import to the ts file where you want to use JSX:

```ts
import {createElement} from "resty.jsx"
```

_Don't forget to change the file extension to `.tsx`!_

Now you can write JSX!

```tsx
return <div>Hello world!</div>
```

### Installing globally

By default, **TypescriptToLua** will put this library to `lua-modules/resty.jsx` under the output directory and change the
Lua `require` correspondingly.

Alternatively, you may want to install it same way as other other libraries that are installed via LuaRocks or OPM.

In this case, you can simply copy [jsx.lua](/lib/resty/jsx.lua) to `/usr/local/openresty/site/lualib/resty/` folder, and
then you need to disable **TypescriptToLua**'s resolution by adding the following line to the **tsconfig.json**:

```json
{
    "tstl": {
        "noResolvePaths": ["resty.jsx"]
    }
}
```

Now the `import` path will not be changed and Lua will pick the library from the global path.

### Performance

This module is optimized for performance and uses [ngx_escape_html function](https://www.nginx.com/resources/wiki/extending/api/utility/#ngx-escape-html)
via FFI. It is quite hard to estimate the overhead and it will vary a lot depending on your markup, in my tests, for a
real-world ~2Kb HTML, the JSX version was about `0.5ms` slower per request than raw string concatenation (with server under load).
