package utils

import (
	"encoding/json"
	"io/ioutil"
)

func LoadData(file string, testData interface{}) error {
	data, err := ioutil.ReadFile(file)
	if err != nil {
		return err
	}
	return json.Unmarshal(data, testData)
}
