# Tables

The main 'geoname' table has the following fields :

```
geonameid         : integer id of record in geonames database
name              : name of geographical point (utf8) varchar(200)
asciiname         : name of geographical point in plain ascii characters, varchar(200)
alternatenames    : alternatenames, comma separated varchar(5000)
latitude          : latitude in decimal degrees (wgs84)
longitude         : longitude in decimal degrees (wgs84)
feature class     : see http://www.geonames.org/export/codes.html, char(1)
feature code      : see http://www.geonames.org/export/codes.html, varchar(10)
country code      : ISO-3166 2-letter country code, 2 characters
cc2               : alternate country codes, comma separated, ISO-3166 2-letter country code, 60 characters
admin1 code       : fipscode (subject to change to iso code), see exceptions below, see file admin1Codes.txt for display
                    names of this code; varchar(20)
admin2 code       : code for the second administrative division, a county in the US, see file admin2Codes.txt; varchar(80)
admin3 code       : code for third level administrative division, varchar(20)
admin4 code       : code for fourth level administrative division, varchar(20)
population        : bigint (8 byte int)
elevation         : in meters, integer
dem               : digital elevation model, srtm3 or gtopo30, average elevation of 3''x3'' (ca 90mx90m) or 30''x30''
                    (ca 900mx900m) area in meters, integer. srtm processed by cgiar/ciat.
timezone          : the timezone id (see file timeZone.txt) varchar(40)
modification date : date of last modification in yyyy-MM-dd format
```

Source: [GeoNames dump](http://download.geonames.org/export/dump/)

### unit test description

La prueba unitaria para la función calculateScore evalúa si la función produce la puntuación correcta para una serie de diferentes escenarios de entrada. Cada escenario de prueba verifica una situación específica y se asegura de que la función calculateScore esté funcionando según lo esperado en cada una de estas condiciones. Estos escenarios incluyen:

    ExactMatch: Comprueba si la función devuelve una puntuación de 1.0 cuando el nombre de la ciudad coincide exactamente con el término de búsqueda y las coordenadas de latitud y longitud también coinciden. Esto simula una coincidencia perfecta.

    NameMatchLatitudeMatch: Verifica si la función devuelve una puntuación de 0.9 cuando el nombre de la ciudad coincide con el término de búsqueda y la latitud coincide, pero la longitud no. Esto simula una alta relevancia por nombre y proximidad en latitud.

    NameMatchLongitudeMatch: Comprueba si la función devuelve una puntuación de 0.9 cuando el nombre de la ciudad coincide con el término de búsqueda y la longitud coincide, pero la latitud no. Similar al anterior, pero con proximidad en longitud.

    NameMatch: Verifica si la función devuelve una puntuación de 0.8 cuando sólo el nombre de la ciudad coincide con el término de búsqueda, sin coincidencia en latitud o longitud.

    LatitudeLongitudeMatch: Comprueba si la función devuelve una puntuación de 0.7 cuando tanto la latitud como la longitud coinciden, pero el nombre de la ciudad no coincide con el término de búsqueda.

    LatitudeMatch: Verifica si la función devuelve una puntuación de 0.6 cuando sólo la latitud coincide y ni el nombre de la ciudad ni la longitud coinciden con los términos de búsqueda.

    LongitudeMatch: Similar al anterior, pero comprobando la coincidencia de la longitud en lugar de la latitud.

    NoMatch: Verifica si la función devuelve una puntuación de 0.5 cuando no hay coincidencias en el nombre de la ciudad, ni en la latitud, ni en la longitud con respecto a los términos de búsqueda.


En cada caso, la prueba llama a calculateScore con los parámetros apropiados y luego compara el valor de retorno con la puntuación esperada. Si alguna de estas afirmaciones falla, la prueba fallará y mostrará un mensaje de error explicando la discrepancia.

Prueba de Integración para el Endpoint /suggestions

La prueba de integración para el endpoint /suggestions verifica que el servidor HTTP esté manejando las peticiones correctamente y devolviendo las respuestas esperadas en formato JSON cuando se accede al endpoint /suggestions. La prueba hace lo siguiente:

    Carga la lista de ciudades llamando a la función loadCities, que es necesaria para que el manejador del endpoint funcione correctamente. Esto asume que el archivo "cities_canada-usa.tsv" está presente y tiene el formato esperado.

    Crea una solicitud HTTP de prueba con un término de búsqueda de "TestCity" y unas coordenadas específicas para la latitud y la longitud.

    Usa httptest.NewRecorder para grabar la respuesta del manejador.

    Llama al manejador suggestionsHandler con la solicitud de prueba y el grabador para que actúe como la respuesta.

    Comprueba que el código de estado HTTP devuelto sea 200 (OK), lo que indica que la solicitud se manejó correctamente.

    Lee el cuerpo de la respuesta y lo deserializa del JSON a una estructura de Go para poder compararlo con la respuesta esperada.

    Compara la respuesta deserializada con la respuesta esperada para asegurarse de que la lista de sugerencias coincida con lo que se espera para los parámetros de la solicitud de prueba.

    La prueba de integración se asegura de que el sistema, cuando se toma como un conjunto, funcione correctamente en un escenario que se acerca al uso real. En este caso, se simula una petición al servidor para verificar que la lógica de negocio (en este caso, sugerir ciudades basadas en un término de búsqueda y coordenadas opcionales) y la capa de presentación (el formato de la respuesta JSON) funcionan de manera conjunta como se espera.

