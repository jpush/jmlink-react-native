import React from 'react';
import {StyleSheet, Text, View, TouchableHighlight, TextInput} from 'react-native';
import JMLink from 'jmlink-react-native';


const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    },
    TextInputStyle: {
        height: 100, 
        width:300, 
        borderColor: 'gray', 
        borderWidth: 1,
        marginTop: 10,
    },
    title: {
        marginTop: 50
    }
});

const initParams = {
  'debug': true,
  'appKey': '极光官网分配的appKey', //仅OS
  'channel': 'channel',                 //仅OS
  //'advertisingId': 'advertisingId',     //仅OS
  'isProduction': false,                //仅OS
};

export default class App extends React.Component {
    _isMounted = false;

    constructor(props) {
        super(props);
        this.state = {
          params: '',
          dynpParams: ''
       }
    }

    componentDidMount() {
        this._isMounted = true;
        JMLink.init(initParams);
        this.getParamListener = params => {
          var paramsText = "";
          var dynpText = "";
          for (let key in params.params) {
            paramsText += key + ":" + params.params[key] +"\n"
          }
          for (let key in params.dynpParams) {
              dynpText += key + ":" + params.dynpParams[key] + "\n"
          }
          
          if (this._isMounted) {
            this.state.params = paramsText;
            this.state.dynpParams = dynpText
            this.setState(this.state);
          }
        };
        
        JMLink.register(this.getParamListener)
    }

    componentWillUnmount() {
        this._isMounted = false;
        JMLink.unregister(this.getParamListener);
    }    

    render() {
        return (
            <View style={styles.container}>
                  <Text style={styles.title}> 获取到的参数:</Text>
                  <TextInput 
                    style={styles.TextInputStyle} 
                    value={this.state.params}
                    editable = {false}
                  />
                <Text style={styles.title}>  无码邀请参数:</Text>
                  <TextInput 
                    style={{height: 100, width:300, borderColor: 'gray', borderWidth: 1}} 
                    value={this.state.dynpParams}
                    editable = {false}
                  />
            </View>
        );
    }
}
